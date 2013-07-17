---
layout: post
title: "buildCrankPkg"
date: 2013-07-17 16:31
comments: true
categories: 
- OS X
- Python
- Script
---

In my last post I promised a tool I've been working on to automate the building of a package for crankd.

buildCrankPkg is a small script that will:

* Pull down the latest version of crankd (or use a local or remote repository if you specify one)
* Build a package that includes crankd and your custom settings and scripts. 
 
I've included two examples, one that implements calling Munki and Puppet as detailed in the last post, and one to call a Casper policy.

## Tutorial

First off, you're going to need to get the buildCrankPkg repository.

{% codeblock %}cd ~/src
git clone https://github.com/grahamgilbert/buildCrankPkg.git{% endcodeblock%}

You're left with three directories that you need to fill:

* ``crankd``: You will be putting your custom code in here.
* ``Preferences``: Just a plist that will call our custom code.
*  ``LaunchDaemons``: A LaunchDaemon to run crankd - an example that should be fine is already there.

Assuming you cloned the ``buildCrankPkg`` repository to ``~/src/buildCrankPkg``, put the following 

{% codeblock lang:Python %}{% github grahamgilbert/buildCrankPkg b451b0dc6a2d8ef0720b499b5ca0815755740cb5 %}
{% endcodeblock %}