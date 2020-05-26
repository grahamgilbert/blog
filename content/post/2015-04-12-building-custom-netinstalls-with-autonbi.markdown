---
categories:
- Python
- NetInstall
comments: true
date: "2015-04-12T20:33:28Z"
title: Building custom NetInstalls with AutoNBI
---

Another day, another tool made by [Mr Bruienne](http://enterprisemac.bruienne.com)! A while back, Pepijn released [AutoNBI](https://bitbucket.org/bruienne/autonbi) - a tool for automating the creation of NetInstall sets. At the time, it was filled away in the "this is cool, but isn't this what System Image Utility does?" section. Then I saw his NetInstall running at MacTech (are you seeing a theme here?). It had this really simple DeployStudio like imagaing app - it was really cool. And suddently it made sense why you can replace the ``Packages`` directory with AutoNBI - a NetInstall is a really stripped down OS X environment, so it it much easier to distribute and use - we're looking at around 1.8GB for my current NetInstall vs 5-6GB for a normal NetBoot.

This time we'll take a look at how to use AutoNBI to make a standard NetInstall - in a future post we'll look at some of the more cool things you can do with AutoNBI.

## Ok, stop talking, let's do this.

We're going to need AutoNBI to start off with. Open up your Terminal and:

``` bash
$ git clone https://bitbucket.org/bruienne/autonbi.git
$ cd autonbi
```

## Prepare the build!

We're ready to go (assuming you've got an OS X installer - you do, right?). Still in your terminal:

```bash
$ sudo ./AutoNBI.py -s /Applications/Install\ OS\ X\ Yosemite.app -d ~/Desktop -n MyNetInstall -e
```

What did we just do? The ``-s`` option is simply pointing at our Install OS X Yosemite.app - if you have it somewhere else, point AutoNBI there. ``-d`` is our destination directory and ``-n`` is the name of our NetInstall. ``-e`` is telling AutoNBI to make the NetInstall enabled.

So the next time there's a new OS X Installer, you can have an updated NetInstall in seconds, not minutes.
