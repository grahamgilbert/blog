---
categories:
  - OS X
  - Automation
  - Puppet
  - Munki
  - Boxen
comments: true
date: "2014-07-26T11:27:00Z"
title: Personal Automation (Part 1)
---

[Earlier this year](http://grahamgilbert.com/blog/2014/04/04/updating-boxen/), I professed my love of Boxen - the personal automation solution based on Puppet released by Github. Indeed, it served me well for quite some time, but I began to find myself spending more time fixing Boxen than actually getting things done. As Boxen was designed for internal use at Github, it set some things up how they liked them - which wasn't necessarily how I liked them. Sysadmins have similar needs to developers, but not exactly the same.

Then I updated Boxen. All of my modules were out of date, so I spent a good couple of hours updating all of them so they worked again. Ugh.

So I started looking at moving to my own solution. One of my major irritations when using Boxen was that it didn't really handle updating your apps - you got whatever version the module author decided to install and then you had to hope that there was an updatng mechanism built in. I've said before that there is no better method of getting software onto your Mac then Munki, so the first decision was straightforward. The rest took a little thought.

## The six P's

My first requirement was that I shouldn't need to run anything to get my configuration to apply. Boxen requires that you run the `boxen` command periodically across each of your Macs to get the configuration applied. This wasn't always practical. I needed something that would run in the background and keep itself up to date.

As I said before, I really disliked how Boxen installs software. Munki does a much better job, and AutoPkg makes it trivial to make sure you have the latest software version. Being a sysadmin, I need more than simple drag and drop apps and packages though - I make extensive use of [Homebrew](http://brew.sh) to install command line tools like [Packer](http://packer.io), so I needed to come up with a way of installing these with Munki.

However, Munki isn't the best tool for managing my configuration. I've been using Puppet to manage the Macs I look after for nearly three years now, and I wanted to base my system on it as I've already done a lot of the work with making OS X specific modules. I also wanted to use the modules made for Boxen as much as possible (some made too many assumptions about where they were running, so couldn't be reused.

So to recap:

- Munki for software deployment.
- Puppet must run in the background periodically
- The configuration must update itself - I don't want to have to sync code across machines.
- Where possible, reuse existing Puppet modules

Over the next few posts, I'll go over the different parts of this solution, how I put it together and how you might be able to use this.
