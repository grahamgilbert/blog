---
title: Managing OS X Profiles with Puppet
date: 2016-03-30T06:17:51.000Z
layout: post
categories:
  - Profiles
  - Puppet
---

There are many ways of managing configuration profiles on OS X - you can use MDM, Munki or any one of the other many great tools. My preferred method however is using Puppet.

By using Puppet, I get access to it's templating features, and I can let others in my team adjust exposed settings through Hiera. Convinced? Let's get going.<!-- more -->

## Prep

Before you do anything, you're going to need a profile. There are [plenty](https://github.com/nmcspadden/Profiles) [of](https://github.com/gregneagle/profiles) [the](https://github.com/golbiga/Profiles) [things](https://github.com/rtrouton/profiles) on Github, or you could run Profile Manager in a VM (please don't use it for anything more than this, it should never be managing your devices directly), or in the future you'll be able to use Erik Berglund's [ProfileCreator](https://github.com/ProfileCreator/ProfileCreator).

This time I'm going to be an evil admin and enforce a desktop picture on my users - there are a couple of profiles on the repositories I linked to above that have an example of this.

We are going to keep our module in git - we'll use GitHub today, as you can get a free repository and the GUI app is really simple. This is not a git tutorial, so all you will need to do it 'commit' your code and sync it to Github. Go ahead and get the [application](https://desktop.github.com) and create a new git repository (File -> New in the app once you've logged in). It doesn't matter what you call the repo, but I like to keep my Puppet modules prefixed with ``puppet-`` so they line up nicely in the Finder.

There is one other thing you will need for today: an OS X VM to test in that has Puppet Agent installed. You can find installers over on the [Puppetlabs downloads site](http://downloads.puppetlabs.com/mac/) ([10.11 direct link](http://downloads.puppetlabs.com/mac/10.11/PC1/x86_64/)). You should use the 'Puppet Collection' versions in the directories marked ``10.9``, ``10.10`` and ``10.11`` - these contain Puppet 4, which is the current version of Puppet.

## The module

Now we're ready to start writing our module. Open up the directory you just made for your git repo, and create directories called ``manifests`` and ``templates`` inside.

``` bash ~/src/puppet-desktop_picture
.
├── manifests
└── templates

```

The first file we're going to create is our profile template. It will be just the same as any profile you've worked with before, but we're putting in a placeholder where you'd normally put in the path to the image you want to be used for the desktop picture. You should probably replace the reverse domain (``com.grahamgilbert``) with ``com.yourcompany``.

``` xml templates/com.grahamgilbert.config.desktop.mobileconfig.erb
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>PayloadDisplayName</key>
			<string>Desktop</string>
			<key>PayloadEnabled</key>
			<true/>
			<key>PayloadIdentifier</key>
			<string>com.grahamgilbert.config.desktop</string>
			<key>PayloadType</key>
			<string>com.apple.desktop</string>
			<key>PayloadUUID</key>
			<string>9EFB0A0A-F64A-4FF4-9477-101295DE7353</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>locked</key>
			<true/>
			<key>override-picture-path</key>
			<string><%= @path -%></string>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>Sets Desktop Picture</string>
	<key>PayloadDisplayName</key>
	<string>Desktop Background</string>
	<key>PayloadIdentifier</key>
	<string>com.grahamgilbert.config.desktop</string>
	<key>PayloadOrganization</key>
	<string>Your Organization</string>
	<key>PayloadRemovalDisallowed</key>
	<true/>
	<key>PayloadScope</key>
	<string>System</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>C7E78A8D-F0E3-4EDC-9BA7-8163E10BA847</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
```

That's our profile template completely finished. If you've seen a profile before, it will be familiar - the only change we've made is on line 23 where we have replaced what would normally be a path to your desired image with ``<%= @path -%>``. This is an erb tag that will be replaced with our path by Puppet.

Now for the manifest. We're going to make use of Sam Keeley's fork of [mac_profiles_handler](https://github.com/keeleysam/puppet-mac_profiles_handler) to handle the installation of our profile. Our module will allow the path to the image we want set as the desktop picture, so we have that as an option at the top of the class. The rest is just telling ``mac_profiles_handler`` to install our profile.

``` puppet manifests/init.pp
class desktop_picture (
    $path = '/Library/Desktop Pictures/El Capitan.jpg'
)
{
    mac_profiles_handler::manage { 'com.grahamgilbert.config.desktop':
        ensure      => 'present',
        file_source => template('desktop_picture/com.grahamgilbert.config.desktop.mobileconfig.erb'),
        type        => 'template',
    }
}

```

That's it for our module - you should open up the Github app and commit your code up to Github, creating a repo when the app asks.

## Testing it out

We're going to use a tool called r10k to deploy our code. It uses git to make sure your code is all in the right place and up to date. Hop over to your VM and open up Terminal.app and bash in:

``` bash linenos:false
$ git --version
```

If you are prompted to install the Xcode command line tools, do so. If you are just told which version of git you have, you're all done.

Next we need to get r10k installed.

``` bash linenos:false
$ sudo gem install r10k
```

And now we need to make our Puppetfile. The Puppetfile simply tells r10k which modules to install. Replace ``https://github.com/grahamgilbert/puppet-desktop_picture.git`` with the HTTPS URL of your git repository for your newly created module. Your Puppetfile can go anywhere on your test VM (in production, you would use something called a [control repo](http://technoblogic.io/blog/2014/05/16/r10k-control-repos/) to manage this).

``` ruby Puppetfile

# This is a hack so we can deploy locally without using a control repo
moduledir "/etc/puppetlabs/code/environments/production/modules"

mod "desktop_picture",
  :git => "https://github.com/grahamgilbert/puppet-desktop_picture.git"

mod "mac_profiles_handler",
  :git => "https://github.com/keeleysam/puppet-mac_profiles_handler.git",
  :ref => 'fc1af5beb3e0d2b6ff577648ef8352e6bb5a6e32'

mod "stdlib",
  :git => "https://github.com/puppetlabs/puppetlabs-stdlib.git",
  :ref => 'c5486aba6284664ae87a65beaa011211c70ea03e'
```

Assuming you saved your Puppetfile on the VM's desktop:

``` bash linenos:false
$ sudo r10k puppetfile install ~/Desktop/Puppetfile -v
```

Now all that's left is to create your ``site.pp`` with a default node that has your class applied to it. You'll need to do this as root (``sudo nano`` for example).

``` puppet /etc/puppetlabs/code/environments/production/manifests/site.pp
node default {
    include desktop_picture
}
```

Let's test it:

``` bash linenos:false
$ sudo /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
```

You should see your profile being applied to your test VM, and if you try to change the desktop picture, you will be prevented from doing so. But what happens if your users need something different?

You have two choices. You could edit your ``site.pp`` to look something like:

``` puppet /etc/puppetlabs/code/environments/production/manifests/site.pp
node default {
    class {'desktop_picture':
        path => '/Library/Desktop Pictures/Grass Blades.jpg'
    }
}
```

But that's just messy. We should be using a better tool for this job: Hiera. As root:

``` yaml /etc/puppetlabs/code/environments/production/hieradata/common.yaml

---
desktop_picture::path: '/Library/Desktop Pictures/Grass Blades.jpg'

```

One final ``puppet apply``:

``` bash linenos:false
$ sudo /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
```

## Wrap up

We've created a module that will apply a profile to our Macs. We've set up a quick test environment, deployed our module and it's dependencies and passed configuration to our module via Hiera. Remember this setup should only be used for testing, as I said before you should be using a control repo with r10k.

If you'd like to see the simple module I made for this post, you can [find it up on Github](https://github.com/grahamgilbert/puppet-desktop_picture).
