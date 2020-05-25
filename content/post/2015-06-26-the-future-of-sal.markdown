---
categories:
- Sal
comments: true
date: "2015-06-26T09:40:31Z"
title: The future of Sal
---
As some of you may know, yesterday was my last day at pebble.it. Since I announced I was leaving, I’ve been getting asked this pretty regularly, so I thought I’d answer it here.

My new job uses Munki extensively, and I expect to be using Sal there. As such, development of Sal will continue. I no longer have commit access to the Sal Software organisation, so I’ve forked the project and have set up [Sal Open Source](https://github.com/salopensource) as an organisation on GitHub - hopefully this will be the last time anything needs to change. I’ll be moving the preference domain in version 0.4.0 of the client side scripts to ``com.github.salopensource.sal`` - once again, this should be the last time things need to change.

So, what else can you expect from Sal in the near future? The next release will have a GUI for managing your plugins, and I’ve started work on a basic API, which should make it easier for people to extend Sal in any language you like. For example, I’ve been working on a way to sign Puppet certificates based on whether it’s a known machine in Sal, with the machine being created via the API if it doesn’t already exist at imaging time (using Imagr, naturally).

It’s exciting times for users of all the projects I’m working on - in addition to these changes, I have some changes planned for [Crypt](https://github.com/grahamgilbert/Crypt), and of course [Imagr](https://github.com/grahamgilbert/imagr) is still on the development rollercoaster.
