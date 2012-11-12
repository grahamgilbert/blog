---
layout: post
title: "Meraki Systems Manager"
date: 2012-11-12 16:07
comments: true
categories: 
-Cloud
-OS X
---
Maintaining visibility over your fleet of machines is always difficult. It's even more difficult when you've got Macs. It gets nearly impossible when you decide you'd like something hosted in the cloud.

We've been looking for a good solution for ages now - we even resorted to using [OCS Inventory](http://www.ocsinventory-ng.org/en/) for a while. We then discovered [Meraki's Systems Manager](http://www.meraki.com/products/systems-manager/).

This isn't going to be one of those fancy review type things - you can go and look at it's features yourself. This is more an overview of the factors that came into our decision:
##Pros
* It's cloud based! No servers for us to deploy, no VPNs between sites for clients to communicate over
* It does basic iOS MDM. It's not the best in the world, but it does a lot of what we wanted (basically configuring email and Wi-Fi settings)
* It has SSH over the Internet. If all else fails, we have a way into a machine, no matter where it is.
* It's free! It's hard to argue with a price like that!

##Cons
* It's free! If you're not paying for something, you have no SLA, no guarantee it will be working tomorrow
* It's location services suck in the UK. My home network is in Sheffield apparently. We supposedly have clients in Bath (we don't).
* It's not particuarly customisable. With Puppet, Facter, Puppet Dashboard and the inventory service configured, you can pull out practically any information you require (for example, we have a Fact that tells us if there are any admin users on a Mac other than our own).

##Summary
For what it does, Meraki Systems Manager is hard to beat. If you need more than basic system information, or something that runs on Linux, you're going to need to look elsewhere. It's a great compliment to Puppet Inventory, but it's not a total replacement.
