---
layout: post
title: "Personal Automation: Munki (Part 2)"
date: 2014-07-27 11:21:37 +0100
comments: true
categories: 
- Automation
- Munki
- OS X
---

The first step to getting any Mac set up is to get some software onto it. I'm not going to cover how to set up [Munki](https://code.google.com/p/munki/wiki/GettingStartedWithMunki) or [AutoPkg](https://github.com/autopkg/autopkg/wiki/Getting-Started) - there are lots of other places for that information.

As a sysadmin, I'm forever testing things. Rather than destroy my own machine, I like to do this in Virtual Machines. My preferred virtualisation solution is VMware Fusion, but unfortunately it's not very easy to deploy out of the box. You need to do a little bit of work to get it into a package that you can import into Munki, but fortunately the process is [well documented on VMware's site](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2058680).

The next piece of 'non standard' software I need is [Homebrew](http://brew.sh). The installation method listed on their site is to run a terminal command as the current user. The first part of this is obviously fine - Munki has several methods to run scripts (payload free packages, nopkg), but it runs everything as root. Fortunately, as I'm deploying my own machine, I can make some assumptions about where Homebrew will be installed. The first assumption I can make is that there will only be one user on the machine, and the second is that I'm going to be logged in most of the time (as my laptop is encrypted, it's either off or logged in).

I'm going to utilise a ``nopkg`` pkginfo file to perform the installation. The first part of our script to install Homebrew is to make sure that a user (me!) is logged in. Homebrew doesn't like being owned by root, so first we need to make sure that there is a user logged in.

{% codeblock lang:bash %}
#!/bin/bash

CURRENT_USER=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

if [ "$CURRENT_USER" == 'root' ]; then
    # this can't run at the login window, we need the current user
    exit 1
fi
{% endcodeblock %}

So now we know that there's a user logged in, and who that user is. Time to install Homebrew as the current user.

{% codeblock lang:bash %}
mkdir -p /usr/local
mkdir -p /usr/local/homebrew
mkdir -p /usr/local/bin
chown $CURRENT_USER:_developer /usr/local/homebrew
chown $CURRENT_USER:_developer /usr/local/bin

#download and install homebrew
su $CURRENT_USER -c "/bin/bash -o pipefail -c '/usr/bin/curl -skSfL https://github.com/mxcl/homebrew/tarball/master | (cd /usr/local ; /usr/bin/tar xz -m --strip 1 -C homebrew; ln -s /usr/local/homebrew/bin/brew /usr/local/bin/brew)'"
{% endcodeblock %}

As we're using a ``nopkg`` with Munki rather than a payload free package, we've not left any receipts, so Munki doesn't know if Homebrew is installed. We're going to use an installs array to tell Munki what to look for when determining whether Homebrew is installed or not.

{% codeblock lang:xml %}
<key>installs</key>
	<array>
		<dict>
			<key>path</key>
			<string>/usr/local/bin/brew</string>
			<key>type</key>
			<string>file</string>
		</dict>
	</array>
{% endcodeblock %}

You might be crying "but Homebrew needs the Xcode Command Line Tools installed!" - and you'd be 100% correct. You have the option of importing the downloaded package into Munki, but I have adapted [Tim Sutton's script](https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh) into a ``nopkg``. To find out what's installed, I ran [fseventer](http://www.fernlightning.com/doku.php?id=software%3afseventer%3astart) and chose a random file to act as my installs array. I've posted the pkginfos for both the [Xcode CLI tools](https://github.com/grahamgilbert/macscripts/blob/master/Munki/pkginfos/Xcode/XcodeCLITools-2014.07.15.plist) and all of the [Homebrew installs](https://github.com/grahamgilbert/macscripts/tree/master/Munki/pkginfos/Homebrew) on Github.