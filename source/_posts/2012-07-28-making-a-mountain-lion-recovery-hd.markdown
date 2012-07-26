---
layout: post
title: "Making a Mountain Lion Recovery HD"
date: 2012-07-28 06:48
comments: true
categories: 
- OS X
- Mountain Lion
- Code
---
A few months ago I made a package to create a Recovery HD on a freshly deployed Lion Mac. It's time to do the same for [Mountain Goat](https://twitter.com/fordy/status/228218744177033216).

In true Blue Peter style, you will need:

* [The Luggage](https://github.com/unixorn/luggage) (If you're having problems getting The Luggage working with the latest version of Xcode, please see [this post on macenterprise](https://groups.google.com/forum/#!topic/macenterprise/v4qRFnCutS4/discussion)
* The [GitHub Repo](https://github.com/grahamgilbert/recovery-hd-mountain-lion)
* A read only DMG of a never booted 10.8 Recovery HD
* The [Lion Recovovery HD Update](http://support.apple.com/kb/DL1464)
<!--more-->
##Getting a 10.8 Recovery HD DMG
First you need the debug menu turned on in Disk Utility. Make sure Disk Utility is quit and put this into Terminal:
``defaults write com.apple.DiskUtility DUDebugMenuEnabled 1``

Open up Disk Utility again, select the Recovery HD and choose New Image. In the resulting pop-up leave the name as Recovery HD and change the format to read-only. Save it, and put it in the folder you cloned the repo to.

{% img  center /images/posts/2012-07-26/Disk_Utility.jpg %}

##Getting dmtest
Open the Recovery HD Update from Apple and run:
``pkgutil --expand /Volumes/Mac\ OS\ X\ Lion\ Recovery\ HD\ Update/RecoveryHDUpdate.pkg ~/Desktop/RecoveryHDUpdate``

Copy dmtest from ~/Desktop/RecoveryHDUpdate/RecoveryHDUpdate.pkg/Scripts/Tools to the folder your cloned the repo to - just a quick ``make pkg`` and you're finished.

