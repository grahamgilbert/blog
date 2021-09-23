+++
date = 2021-01-14T12:00:00Z
lastmod = 2021-01-14T12:00:00Z
title = "A pragmatic approach to endpoint security"
+++

The the past four and a half years I’ve worked on a rapidly expanding fleet, in a very fast moving environment. In that time, I’ve developed a pragmatic approach to security.

## Standard users do not increase security

I used to think standard users were good for security - even at one point calling them essential. Users couldn’t make changes to their devices, which meant that everything was supposed to be in my desired state. In reality what happens is an annoyed user wants to do something and they call the help desk. Eager to unblock the user, the help desk person shoves the admin password in without many (or often, any) questions.

So what about a tool such as [Privileges](https://github.com/SAP/macOS-enterprise-privileges)? Well, unless you are auditing every change the user makes whilst running with admin rights, then you might as well save yourself the work of deploying it. And if you’re monitoring the changes then, why can’t you monitor for risky changes all the time? And don’t forget, once the user is an admin, they can just give themselves admin rights forever.

Standard users have a much stinkier byproduct: the local IT admin account. If the user runs as a standard user, there will probably be an admin account around for IT to use. Often this is a common password on all of the devices, which is rarely rotated and can often unlock FileVault as well. So we have an unaudited method to not only unlock user data when it is encrypted, but have a common password across our entire fleet. Yikes.

But what about users who forget their password? I would suggest using the FileVault key that you have escrowed to a a tool where retrieval is auditable, such as [Crypt](https://github.com/grahamgilbert/crypt) to reset the users password. These are unique per device and can easily be rotated when they are used.

## What about security products?

Many endpoint security tools are notoriously detrimental to the performance of endpoints, requiring so many exclusions that they might as well not be installed (we had a script that unloaded the kernel extension for a security product we have since stopped using every time an engineer kicked off a build - i.e half the time). And even worse - many security tools don’t have zero day support for new OS releases - any security product that stops you installing OS patches are no longer anything other than a **security vulnerability themselves**.

## Automate everything

Humans make mistakes. Manually configuring things is going to end in tears.

There are far too many opportunities for endpoint automation to cover here, but here are a couple:

- Device wipe from inventory - when your helpdesk marks the device as lost or stolen in your inventory tool, they shouldn't need to go to your MDM to perform the wipe or lock (or even think about whether they should be wiping or locking) - it should just happen for them.
- Apply configuration depending on who is using the device - is the user in a high risk location? Automatically apply your hardening configuration.

For items that Apple doesn’t expose a method to configure via mdm, don’t rely on a random bash script that makes the change once - there are countless examples of changes being reset when an update is applied. your management tool needs to be verifying the state of the device and making corrective changes as needed. This could be as simple as a script that checks if the change needs to be made again, but even though their useful life may be coming to an end, a configuring management tool such as Puppet, Salt or Chef are the easiest and most robust method of ensuring the state of the device is maintained.

## The number one, easiest thing you can do to keep your fleet secure: Patching

There are several examples of Apple either not fully patching operating systems other than the current shipping one, leaving devices not running the latest operating system vulnerable for weeks (if it is even patched at all). If you are not running the latest version of macOS, you are potentially running the risk of a trivial security breach.

## How to keep patched

- Enforce updates with a profile
- Munki / autopkg - unless the software truly is mission critical, trust the software developers and deploy quickly (particularly for browsers)

Enforcing macOS updates is more fun these days. We've found the best solution in our environment is to block access to services if the device is out of date or if we don't trust the device for other reasons (I've plans to go more into device trust in a future post). It is important to make patching their device the same as turning up for work - it just needs to become something user's get used to doing, and if they don't want to do it? Well, that's not a problem where the best solution is technological.
