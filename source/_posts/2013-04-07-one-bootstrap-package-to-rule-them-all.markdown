---
layout: post
title: "One bootstrap package to rule them all"
date: 2013-04-07 15:36
comments: true
categories: 
- OS X
- Packaging
- Script
---
At work, we've recently changed how we build our bootstrap package to having the main code that connects a Mac to our Puppet infrastructure pulled down from GitHub when the client boots up for the first time.

## Why?

This might sound like madness to you. Why would anyone want to do this? We had two main issues to solve:

* I got sick of rebuilding our images every time our bootstrap script changed.
* Our engineers got sick of downloading the latest version of our package every time they thin / no-imaged a Mac.

Why would our script change so much? In our case, it is to install the latest versions of Puppet and Facter. This isn't strictly necessary, as we update Puppet and Facter with Munki, but occasionally there will be something in our Puppet config that requires a specific version - for example, when we started configuring usernames on 10.8 Macs with Puppet, the ``salt`` parameter was introduced. This required Puppet 3.0.2-ish or higher - which meant that any NetRestore image or old package that contained a version of Puppet lower than this would fail, and the engineer on site was in for a world of pain.

## Ok, I'm convinced.

I've put an [example up on GitHub](https://github.com/grahamgilbert/macscripts/tree/master/Puppet-Bootstrap). This is a sanitised version of the bootstrap script we use at pebble.it. All we do in the script that gets deployed to the client is set the address of our Puppet server and then pull the rest of the script from GitHub - if you don't need to set any variables, you could do all of the work in the remote script.

So this can be used with all of the deployment methods we use at pebble.it ([imaging](https://code.google.com/p/instadmg/), [createOSXinstallPkg](http://managingosx.wordpress.com/2012/07/25/son-of-installlion-pkg/) and no imaging), we do the actual work in a script that is triggered by a launch daemon, so we can be sure we're a) performing the work in a full OS X environment (we need Python to be available for our script) and that we're running it on the boot volume of the client Mac (we need the serial number, and this could be installed via Target Disk Mode when no-imaging.

So when the bootstrap script needs to be updated, rather than rebuilding the package and distributing it to engineers and baking it into images, the workflow becomes:

1. Update script, push to GitHub.
2. Restore image with [puppet_bootstrap.pkg](https://github.com/grahamgilbert/macscripts/tree/master/Puppet-Bootstrap) baked in or install the package manually.
2. Mac boots, downloads the latest version of [``install_puppet.py``](https://github.com/grahamgilbert/macscripts/tree/master/Puppet-Install).
3. ``install_puppet.py`` downloads and installs the correct versions of Puppet and Facter and configures Puppet.
4. Puppet downloads, installs and configures Munki along with all of the other configuration.
5. PROFIT

This clearly isn't required or suitable for all types of script - but if you have a package that is frequently updated and you have staff installing it by hand, this is a relatively simple way to make sure they've got the latest version at all times.