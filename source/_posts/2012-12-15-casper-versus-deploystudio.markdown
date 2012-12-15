---
layout: post
title: "Casper versus DeployStudio"
date: 2012-12-15 13:00
comments: true
categories: 
- OS X
- Deployment
---
I'll preface this with one thing - I'm not a Casper Suite expert. I don't use it reguarly, and at what it costs, I probably won't! It's this price that gave me high expectations for this last install. Unfortunately they were unfounded.

I'm hoping to write a series of articles comparing the various aspects of Casper against the free tools I use every day. First up is DeployStudio.

##Workflow creation
Both Casper Imaging and DeployStudio have a nice GUI for creating the workflow. It's just a drag and drop to place the tasks you need. The DeployStudio interface feels a bit more polished, but that's probably just my bias showing though. The only real differentiator here are the package groups that DeployStudio offers. If you had a standard group of packages that you deploy over several different workflows, DeployStudio makes it easy to maintain - yes, this should probably be done elsewhere, but it can be handy to install a certain set of applications at imaging time. I couldn't see a direct replacement for this in Casper Imaging.

__Winner: Draw (just! if pushed, I'd say DeployStudio just edged it)__

##NetBoot
This is where DeployStudio really starts to poop on Casper Imaging from a great height. With Casper, the chap doing the jump start told me that I had to manually build up a NetBoot image with Casper Imaging set up. Hilarious. Surely he was joking, right? No. DeployStudio, a _free product_, has a wizard for making a customised NetBoot set that offers an iTunes like interface that is so simple, I've regularly taken an office manager through imaging a Mac. I dread to think how that same person would cope with the random UI elements that have been thrown at the screen when making the casper imaging app.

__Winner: DeployStudio, hands down. Casper didn't even turn up__

##Imaging process
So, you've managed to get past the lovely Casper Imaging interface, and now you're installing a package that's best installed when running from the target system - like an Adobe CS package. One that is likely to be the biggest package you're installing. With DeployStudio, you at least get some indication that _something_ is happening - you have the log scrolling by in the background. With Casper Imaging you get nothing other than a back window, and the nice Casper logo. No idea if it's going to take five minutes or two hours. 

__Winner: DeployStudio__

I'll finish this post with an admission: I don't use DeployStudio either. I've been trying to get rid of OS X in my server rooms, so as I mentioned in my last post, we're using JAMF's NetSUS appliance (dear JAMF, why can you make an awesome free product like NetSUS, but your flagship product be so poor?) and NetRestore with a InstaDMG made image with just an OS and a package to hook it into Puppet. I chose to compare Casper Imaging with DeployStudio as they're closer competitors than the one trick pony of NetRestore.
