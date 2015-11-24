---
layout: post
title: "Location based printers with Puppet"
date: 2012-08-18 21:08
comments: true
categories: 
- Puppet
- Mac OS X
---
This will probably be obvious to most seasoned Puppet inclined OS X admins, but this is a relatively recent revelation for me. Up until very recently, I wasn't really making full use of Facter, merely pointing my clients to the appropriate classes and leaving it at that. When tasked with giving end users the option to install their own printers when they went to a different site than the one they usually work at, my initial thought was to go for a Payload-free package and pop it into their optional installs in Munki. But then I was asked if it could happen without the user doing anything - they go to the other site, and they automatically get the right printers set up - so after a little thought,  came up with this. I've made use of the excellent [mosen-puppet-cups](https://github.com/mosen/puppet-cups) module on GitHub to get the printers set up, and the drivers are already deployed with Munki (I did consider moving them to Puppet, but why reinvent the wheel for the sake of it?).

{% gist 3389457 %}