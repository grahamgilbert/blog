---
categories:
  - munki
  - python
date: "2015-12-13T13:55:13Z"
title: Automated timed releases with Munki
---

In my environment, we have software that needs to be deployed at the same time across all of our sites. Previously, this meant someone had to pull their computer out on a Sunday and promote the item from the testing catalog to the production catalog. Which is fine, but to be honest I'd rather be doing something else on a Sunday!

So I started looking at how to automate this process. First I looked at [`force_install_after_date`](https://github.com/munki/munki/wiki/Pkginfo-Files#force-install-after-date), but this install the item at a specified time in the client's local time - I needed this to be installed at the same time globally. Next was [Munki's `date` condition](https://github.com/munki/munki/wiki/Conditional-Items#built-in-conditions) and using `installable_conditon` in the item's pkgsinfo file similarly to how we [shard our updates](http://grahamgilbert.com/blog/2015/11/23/releasing-changes-with-sharding/) - but despite the time object looking like it's UTC, it's still just the client's local time. <!--more-->

## What can we do?

I wrote a [simple condition script](https://github.com/grahamgilbert/macscripts/tree/master/Munki/Condition%20Packages/utctime) that will give us both the date and time in UTC and the current unix timestamp - the number of seconds since January 1st 1970. Using the unix timestamp makes it nice and easy to do comparisons on. For example, let's say we want to deploy an item at 8am on Sunday 13th December 2015:

```xml
<key>installable_condition</key>
<string>timestamp &lt;= 1449993600</string>
```

And let's have a look at the script:

```python /usr/local/munki/conditions/utctime
#!/usr/bin/env python
import subprocess
import os
import plistlib
from datetime import datetime
import time

from Foundation import CFPreferencesCopyAppValue

# Read the location of the ManagedInstallDir from ManagedInstall.plist
BUNDLE_ID = 'ManagedInstalls'
pref_name = 'ManagedInstallDir'
managedinstalldir = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
# Make sure we're outputting our information to "ConditionalItems.plist"
conditionalitemspath = os.path.join(managedinstalldir, 'ConditionalItems.plist')

def main():

    newdict = dict(utctime = datetime.utcnow(), timestamp = int(time.time()))

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


if __name__ == '__main__':
    main()
```

Just deploy that to `/usr/local/munki/conditions/utctime` and you're good to go - if you'd like to use a pre-built package, you'll find one up on [GitHub](https://github.com/grahamgilbert/macscripts/tree/master/Munki/Condition%20Packages/utctime).
