---
categories:
  - munki
  - puppet
  - ruby
  - python
  - sharding
date: "2015-11-23T19:16:02Z"
modified: "2015-11-24T09:16:02+00:00"
title: Releasing Changes With Sharding
---

Sharding is traditionally associated with databases - splitting up your dataset to make it more manageable. When using the term in this instance we are taking about splitting up our computers - there are several reasons you might want to do this. You might want to split them up for similar performance reasons - if you're deploying large software updates your server might not be able to cope with all your clients pulling it at once. You might want a way to roll changes out to certain groups of machines.

Facebook spoke about sharding at [macbrained in May 2015](http://macbrained.org/recap-may-quantcast/), but they weren't clear on how they use it (**edit:** they actually first spoke about it at [MacSysAdmin](https://macsysadmin.se/2014/Thursday.html)). A few people were pretty interested in using this method of rolling out changes to their machines, but it was [Victor Vrantchan](http://groob.io/) who came up with a [method of deriving a value between one and 100 based on the machines serial number](https://github.com/whitby/mac-scripts/tree/master/munki_condition_shard) (**edit:** this was based on [Facebook's](https://github.com/facebook/IT-CPE/blob/master/code/lib/modules/sys_tools.py#L161) and [Google's](https://github.com/google/macops/blob/master/gmacpyutil/gmacpyutil/experiments.py) code. Elliot Jordan also came up with something [similar for Casper](https://gist.github.com/homebysix/b35f1979d5b11e00602c)).

Using this condition as a base and a similar Facter Fact I've started using the method outlined below to release changes to the macs I look after. <!--more-->

## The process

Since the condition and fact gives me a nice number between 1 and 100, I've split my machines into four groups - the lower 25%, the lower 50%, the lower 75% and general release group (all of the machines) - the first three groups comprise of shards 1 to 3. For normal software or config change releases (where there are no major security implications of delaying release), the software is tested by IT for installation issues and major, obvious bugs. Once this has been concluded, we use the following process:

- Software is released to shard 1 (lower 25%).
- If no issues are reported, after 72 hours, the change is promoted to shard 2.
- After a further 48 hours, the change is promoted to shard 3.
- Once a final 48 hours has passed, the change will be promoted to general release.

If any issues are found at any stage, it will go back to the beginning of the process.

## Which shard is Jim-Bob in?

This whole system falls down if your IT staff don't know what to expect when they build a machine. Of course they can run `facter -p` or look at the `ManagedInstallReport.plist`, but that's not exactly scalable. Your reporting tool should do this for you. I've written a [plugin](https://github.com/salopensource/grahamgilbert-plugins/tree/master/shard) for [Sal](https://github.com/salopensource/sal):

{{< figure class="center" src="/images/posts/2015-11-23/Sal-shard.png" width="300" title="px" >}}

## But what about my bosses bosses boss?

Of course there are machines you absolutely don't want to be testing things on. Important people, your mum, whoever. Conversely, there will be people you want to be out there on the front lines testing everything you can throw at them. Let's take the [condition](https://github.com/grahamgilbert/macscripts/tree/master/Munki/Condition%20Packages/shard) (as my ruby in the [Fact](https://github.com/grahamgilbert/puppet-mac_admin/blob/master/lib/facter/shard.rb) will probably offend your eyes). If `/usr/local/shard/production` is present, the machine always gets a shard value of `100`. If `/usr/local/shard/testing` is present, the machine will get a shard value of `1`:

```python /usr/local/munki/conditions/shard
#!/usr/bin/env python
import hashlib
import subprocess
import os
import plistlib

from Foundation import CFPreferencesCopyAppValue

MOD_VALUE = 10000
# Read the location of the ManagedInstallDir from ManagedInstall.plist
BUNDLE_ID = 'ManagedInstalls'
pref_name = 'ManagedInstallDir'
managedinstalldir = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
# Make sure we're outputting our information to "ConditionalItems.plist"
conditionalitemspath = os.path.join(managedinstalldir, 'ConditionalItems.plist')


def get_serial():
    '''Returns the serial number of this Mac'''
    cmd = ['/usr/sbin/ioreg', '-c', 'IOPlatformExpertDevice', '-d', '2']
    output = subprocess.check_output(cmd)
    for line in output.splitlines():
        if 'IOPlatformSerialNumber' in line:
            return line.split(' = ')[1].replace('\"','')
    return None

def get_shard():
    if os.path.exists('/usr/local/shard/production'):
        shard = 100
    elif os.path.exists('/usr/local/shard/testing'):
        shard = 1
    else:
        serial = get_serial()
        sha256 = int(hashlib.sha256(serial).hexdigest(),16)
        shard = ((sha256 % MOD_VALUE) * 100) / float(MOD_VALUE)

    newdict = dict(shard = int(shard))

    # CRITICAL!
    if os.path.exists(conditionalitemspath):
        # "ConditionalItems.plist" exists, so read it FIRST (existing_dict)
        existing_dict = plistlib.readPlist(conditionalitemspath)
        # Create output_dict which joins new data generated in this script with existing data
        output_dict = dict(existing_dict.items() + newdict.items())
    else:
        # "ConditionalItems.plist" does not exist,
        # output only consists of data generated in this script
        output_dict = newdict

    # Write out data to "ConditionalItems.plist"
    plistlib.writePlist(output_dict, conditionalitemspath)

get_shard()
```

## The joy of sharding

There are two primary benefits in my organisation to sharding. The first is the obvious - it allows us to smoke test changes and updates and potentially roll them back if they have any adverse effect on our fleet before too many machines are effected. The second is an important consideration if you have a large, dispersed fleet. We have a large number of at home workers - by staggering the number of machines pulling the update at once, we can avoid a thundering heard situation on our primary servers without having to use more expensive CDN-backed bandwidth (which we still use when we have a time critical update).

## Using sharding with Puppet

Puppet is our primary configuration management tool for our OS X devices - and as we are quite literally using code to define our configuration, it's really easy to use the shard value to limit who gets which configuration:

```puppet
if $shard <= 25 {
    notify{'shard value is less than or equal to 25': }
}
```

Or to use it for something more useful, let's say we are going to use different [Reposado](https://github.com/wdas/reposado) branches depending on which shard they fall into:

```puppet
if $shard <= 25 {
    $shard_sus_url = 'http://sus.company.com/sus/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_shard1.sucatalog'
}
elsif $shard <= 50 {
    $shard_sus_url = 'http://sus.company.com/sus/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_shard2.sucatalog'
}
elsif $shard <= 75 {
    $shard_sus_url = 'http://sus.company.com/sus/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_shard3.sucatalog'
}
else {
    $shard_sus_url = 'http://sus.company.com/sus/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1_production.sucatalog'
}

class mac_admin::sus {
    sus_url_1011 => $shard_sus_url,
}
```

## Using sharding with Munki

You have a few more options when you're sharding software with Munki.

Usually, when I'm ready to move onto the sharding phase of release, I move the item into the production catalog and add `installable_condition` to it's pkgsinfo file to limit installs to the right shard:

```xml
<key>installable_condition</key>
<string>shard &lt;= 25</string>
```

This is fine if there are other versions of that particular item in your production catalog. If it's a new item, your reporting tool is going to get filled up with warnings.

![Install warnings in Sal](/images/posts/2015-11-23/Sal-warnings.png)

This might not worry you - maybe you don't have a reporting tool for Munki (you're doing it wrong) or you don't care about warnings (you're only doing it slightly less wrong).

The way around this is to use [`conditional items`](https://github.com/munki/munki/wiki/Conditional-Items) for the first release of a particular item. This means that no machines will fail to find the item in a catalog (remember that putting an item into `managed_installs` means you're telling Munki that the item _must_ be installed on this client), as they are only adding it to their `managed_installs` when the condition is met. This of course has the downside of you now having two places to manage the sharding of your Munki items. This may be an acceptable trade off to keep your warnings useful (as it is to me).

## Wrap up

This is only the beginning of my use of sharding. I'm sure there will be improvements and refinements along the way, but it has worked well for me so far.

Links:

- [Munki condition](https://github.com/grahamgilbert/macscripts/tree/master/Munki/Condition%20Packages/shard)
- [Facter fact](https://github.com/grahamgilbert/puppet-mac_admin/blob/master/lib/facter/shard.rb)
- [Sal](https://github.com/salopensource/sal)
- [Sal Plugin](https://github.com/salopensource/grahamgilbert-plugins/tree/master/shard)
