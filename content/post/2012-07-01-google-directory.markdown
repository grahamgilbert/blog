---
categories:
- Cloud
- LDAP
comments: true
date: "2012-07-01T00:00:00Z"
title: Google Directory?
---
Last week at work we were discussing where we were headed. Our email is now firmly in the cloud with Google providing a better infrastructure than we ever could. They've also got word processing and spreadsheets solved for most people with the hard to beat price of free. 

So, what else could we do better with the cloud? <!--more-->

Despite what Dropbox and Google Drive promise, we're some way off moving our file servers into the cloud (just try saving your 11Gb Photoshop file up to the cloud with the average business grade Internet connection, let alone a normal home connection). 

Our configuration system (Puppet) works quite happily from the datacentre on a VM, so there's not really much to worry about with that one. Web and FTP have long since been such a quick race to the bottom that it's practically free to have those in the cloud with services like CloudApp and WeTransfer. 

But what about our directory server? Sure, we can sync Google Apps with our Open Directory or Active Directory, but why should we need one? All of our user information is already in Google Apps, why can't we use that for user authentication? Just think of it, never having to worry about whether the user was at one of your sites or hooked up to a VPN when their password expires and needs to be changed, no more setting up flaky OD replicas, no more Windows Server CALs - maybe they could even add in some basic MDM like they have for iOS - remote wipes and the like. 

Make it happen Google, you can have that idea for free.