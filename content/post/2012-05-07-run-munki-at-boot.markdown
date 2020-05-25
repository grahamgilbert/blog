---
categories:
- Munki
- Deployment
comments: true
date: "2012-05-07T00:00:00Z"
title: Run munki at boot
---
Munki is great. It keeps your macs up to date - well it does most of the time. Sometimes you get a user that just refuses to click on "Update" now matter how many times it pops up. Now you have a tool to defeat them - install this package over ARD and munki will install everything that's available, including Apple software updates (it will reboot the mac if needed and carry on where it left off). 

I wish I could take credit for all this [amazingness](http://code.google.com/p/munki/wiki/BootstrappingWithMunki), but I just wrapped it up into a package. The source is over at [GitHub](https://github.com/grahamgilbert/Munki-Bootstrap), and there's [a pre built package](https://github.com/downloads/grahamgilbert/Munki-Bootstrap/Munki_Bootstrap.pkg.zip) as well.