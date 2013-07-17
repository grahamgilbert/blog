---
layout: post
title: "buildCrankPkg"
date: 2013-07-17 16:31
published: draft
comments: true
categories: 
- OS X
- Python
- Packaging
- Munki
- Puppet
- Casper
- Script
---

In my [last post](http://grahamgilbert.com/blog/2013/07/12/using-crankd-to-react-to-network-events/) I promised a tool I've been working on to automate the building of a package for crankd.

[buildCrankPkg](https://github.com/grahamgilbert/buildCrankPkg) is a small script that will:

* Pull down the latest version of crankd (or use a local or remote repository if you specify one)
* Build a package that includes crankd and your custom settings and scripts. 
 
I've included two examples, one that implements calling Munki and Puppet as detailed in the last post, and one to run a Casper policy.

If you're happy with what crankd does and using the command line, head on over to the [repository](https://github.com/grahamgilbert/buildCrankPkg) and enjoy. If you need a bit more help to get started, read on.<!--more-->

## Tutorial

First off, you're going to need to get the buildCrankPkg repository.

{% codeblock lang:bash %}cd ~/src
git clone https://github.com/grahamgilbert/buildCrankPkg.git{% endcodeblock%}

You're left with three directories that you need to fill:

* ``crankd``: You will be putting your custom code in here.
* ``Preferences``: Just a plist that will call our custom code.
*  ``LaunchDaemons``: A LaunchDaemon to run crankd - an example that should be fine is already there.

Assuming you cloned the ``buildCrankPkg`` repository to ``~/src/buildCrankPkg``, save the following as ``~/src/buildCrankPkg/crankd/CrankTools.py`` (or copy the example). The only change between this one and the ``CrankTools.py`` from last time is that we're calling the JAMF binary to run a Casper policy (I know, the horror, I do actually use Casper occasionally). Our trigger's name is NetworkTrigger - the line you'd need to customise to change this is ``28``.

{% codeblock lang:python CrankTools.py %}{% github grahamgilbert/buildCrankPkg 6663f50f6bb06ff46399159fd69032566414b748 %}
{% endcodeblock %}

Now for the preferences - no change from last time here, as we've not changed the name of our class or method. This goes into ``~/src/buildCrankPkg/Preferences/com.googlecode.pymacadmin.crankd.plist``

{% codeblock lang:xml com.googlecode.pymacadmin.crankd.plist %}{% github grahamgilbert/buildCrankPkg f2dd6bb700db8dcf572dd5b7f39d078030bf6c9c %}
{% endcodeblock %}

One last step until we can build our package is the Launch Daemon - we're going to use the one that's included in the repository, as 99% of people won't need to change it.

## Prepare the build!

Our package needs to have the version number of 2.1 and we're going to set the package's identifier to com.example.crankd

{% codeblock lang:bash %}cd ~/src/buildCrankPkg
sudo ./buildCrankPkg.py  --version 2.1 --identifier com.example.crankd
{% endcodeblock %}

Your package will be in ``~/src/buildCrankPkg`` waiting for you.

