---
title: Custom DEP Packages
date: 2017-12-13T20:42:55-08:00
layout: post
categories:
 - DEP
 - High Sierra
 - MDM
---

I'm sure everyone who didn't have an MDM a few weeks ago is scrambling to get one set up - I'm not going to go into anything about MDM, since it really isn't that interesting. They install profiles and packages - all very unexciting.

This article will take you through some of the decisions we made when developing our DEP enrollment package.

# First attempt

If you are of the open source management tool persuasion, chances are that like me, you are very happy with what you have already and see MDM merely as a method for delivering those tools. Before we considered MDM, our deployment workflow was essentially:

- Imagr lays down a base image
- Imagr installs [Google's Plan B](https://github.com/google/macops-planb)
- Plan B install Puppet
- Puppet performs the configuration
- As part of that configuration, Puppet installs [Munki](https://github.com/munki/munki)
- Munki installs the software

So it looked pretty simple for us to use our existing Plab B package with InstallApplications via an MDM.

# DEPNotify

[DEPNotify](https://gitlab.com/Mactroll/DEPNotify) is a great tool by Joel Rennich - you can pass in various commands and it will let your users know what is going on. So we would open up DEPNotify and then kick off our Plan B installation. Which could sit there for 10 minutes without letting the user know what was happening other than "something is happening". Whilst this obviously wasn't a great experience for our users, it got the job done.

Plan b runs

No notifications

Not a great user experience - slow etc

# First optimization

What do users need to do? Change password, logged into SSO etc

Install chrome - want to let IT time get on as quickly as possible
Install and configure crypt - get the disruptive reboot out of the way and let the user use their computer

# File Watcher

Checking for depnotify running
deciding what is important / takes time

# Overweight packages

With chrome, package was nudging 100mb - this left the user sitting at setup assistant with no idea that anything was happening apart from a spinning cog.

Looked at erik gomez's InstallApplications - found it wasn't flexible enough for us, but happily stole many of it's ideas.

DEP bootstrap package reduced down to a few scripts and launchagents. It then downloads depnotify and the other parts

# Threads

Running plan b and then running munki afterwards was fine when we were imaging. The tech doing the imaging would kick the machine off and then go do something else whilst they waited for the machine to finish building. We couldn't do this with a DEP style deployment - we needed to get everything completed as fast as possible. Threads to the rescue!

Quick overview of what threads are

How we used threads to fire off the Munki run asap

# Final touches

Our particular mdm doesn’t offer authentication during DEP enrollment at the moment - this doesn’t particularly bother me as there is no support for saml or 2fa. We are in the process of writing something to solve this, but for now it is sufficient to ensure the device is in our inventory and is assigned to a user before enrollment continues. To solve this, we wrote a small webapp that queries inventory and returns a Boolean to the launchdaemon. If the device is unassigned the process halts and uses dep notify to let the user know what has happened and to contact our support folks. This is only useful to us because we are treating mdm merely as a delivery mechanism - the user is unable to proceed to get a puppet certificate signed, so will be unable to get a correctly configured machine.

Existing machines and depaetupdone