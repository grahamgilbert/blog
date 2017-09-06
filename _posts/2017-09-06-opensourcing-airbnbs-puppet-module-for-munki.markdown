---
title: Open sourcing Airbnb's Puppet module for Munki
date: 2017-09-06T15:43:38-07:00
layout: post
categories:
 - Open source
 - Puppet
 - Munki
---

It's probably no secret that we use [Puppet](https://puppet.com/) to configure our macOS fleet at Airbnb. And whilst we have given several talks about how we use Puppet on macOS, there was still a lot of hand waving about how we had our modules set up.

So, after several months of me saying "I should open source that", here is our first open source Puppet module: [puppet-munki](https://github.com/airbnb/puppet-munki).

## What does it do?

As you may have guessed, it is a Puppet module that installs and configures [Munki](https://github.com/munki/munki/). More specifically:

* It will install your specified version of Munki, making sure all of it's services are loaded (so no need to reboot when upgrading!)
* It will generate and install a configuration profile that covers all (probably!) of Munki's preferences
* Supports local only manifests so managed installs and uninstalls can be specified with the module
* Is fully configurable with Hiera, so configuration can be specified as generally or as granularly as you need
* Supports an optional background auto run after Munki has been installed, allowing Munki to get to work installing things whilst your initial Puppet run continues
* Will repair (re-install Munki and the profile) if Munki hasn't run successfully after a configurable number of days
* Includes some Facts about the Munki version installed, the packages installed and a function to determine whether Munki has installed an item (useful if you are installing a package with Munki but need to perform additional configuration with Puppet)

## Is something broken? Want to help make this better?

Whilst this module has been in development here for several months, there is always room for improvement. Please file issues and pull requests if you have any suggestions or problems.

This isn't the only module we have planned for release, so watch this space.
