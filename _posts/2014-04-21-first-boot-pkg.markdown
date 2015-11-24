---
layout: post
title: "first-boot-pkg"
date: 2014-04-21 09:01:24 +0100
comments: true
categories: 
- OS X
- Python
- Deployment
---
There are some packages that can't be deployed to an unbooted OS, such as when building an image with AutoDMG. If you are using Greg Neagle's [createOSXinstallPkg](http://managingosx.wordpress.com/2012/07/25/son-of-installlion-pkg/), the OS X installer environment doesn't have everything a full OS X install has. For times like this, you need to install the packages at first boot. For a long time, I've used Rich Trouton's [First Boot Package Install](http://derflounder.wordpress.com/2014/04/17/first-boot-package-install-revisited/), however I found myself repeating things quite a bit and having a folder full of first boot packages.

So, I made my own. The main features of [first-boot-pkg](https://github.com/grahamgilbert/first-boot-pkg) are:

- It is designed with scripting and automation in mind, with options able to be configured with a configuration plist or via options on the command line (or a mixture of both)
- It will re-try failed packages a specified number of times (in case of Active Directory not being available, for example)
- Will wait for the network to be available before installing (optional, can be disabled if desired just in case your package is going to let the Mac get onto the network)

[{% img  center /images/posts/2014-04-21/first-boot-pkg.png 578 433 %}](/images/posts/2014-04-21/first-boot-pkg.png)

If you're happy with using Git, I'd recommend just making a clone of the repository and doing a ``git pull`` to keep the script updated. If the thought of all those gits and pulls makes you run away, you can [download a zip](https://github.com/grahamgilbert/first-boot-pkg/archive/master.zip) of the project.

This script makes use of Per Olofsson's [LoginLog](https://github.com/MagerValp/LoginLog) for displaying the log file whilst the script is running, so massive thanks to him for releasing it.