---
layout: page
title: Talks
comments: false
sharing: true
footer: true
private: true
---

## Puppet on OS X

{% youtube Z2quMhdgILo 420 315 %}

Configuration management and DevOps are the current buzzwords bandied around, but how can they be applied to managing OS X? This session took a look at where Puppet fits into the Mac Management ecosystem, how it can be used in combination with Facter to apply dynamic configuration to OS X and looked at some common use cases. ([slides](http://grahamgilbert.com/images/posts/2016-02-09/Puppet_On_OS_X.pdf))

## Hands on with Imagr (MacTech Conference, 2015)

This session introduced participants to [Imagr](https://github.com/grahamgilbert/imagr), the open source OS X deployment tool. Workshop participants got hands on with Imagr, going from setting up the server environment to configuring Imagr and deploying an OS X machine. [(slides)](/images/posts/2015-11-12/ImagrLab.pdf)

## Twisting Munki (MacTech Conference, 2014)

Munki is one of the best tools for installing software on a Mac, but it isn't a configuration management system. It does however, share certain traits with them. We'll take a look at how Munki can be used to apply configuration to OS X devices, how we can use some of the mechanisms that Munki provides to ensure that the desired state is maintained and how we can use some of Munki's features to make it behave more like dedicated configuration management tools. Along the way we'll take a look at some methods for applying some of the more common (and some of the stranger!) settings on OS X using profiles, payload free packages and the command line. [(slides and code)](https://github.com/grahamgilbert/mactech_2014)

## Automate yourself out of a job (Penn State MacAdmins, 2014)

{% youtube sjbESCx-G48 420 315 %}

Many new mac admins start off by accident. First there are a few macs, then there's a whole lab of them. And before you know it, you're managing hundreds of them. Techniques that worked with a few machines are no longer scalable without an army of staff. When you could once set up each new mac and user by hand, you now need a repeatable, automated method of deploying your customisations and preferences to your machines.

This session will cover how to configure default user preferences on first login, how to create and deploy managed preferences via profiles, how to package your configurations so they can be deployed by tools such as ARD or Munki and how to make OS X images with your customisations built in the easy way. [(pdf)](/images/posts/2014-07-10/Automate_yourself_out_of_a_job.pdf)

## Multi Tenanted Munki with Puppet and Sal (Penn State MacAdmins, 2014)

{% youtube BPTJnz27T44 420 315%}

I spoke about how I tackled the problem of managing multiple Munki stallations by automating the configuration of the remote cache repositories, dynamically configure the clients based on their location and how we empowered our clients by giving them detailed information on their Mac estate with Sal (the Munki Puppet). [(pdf)](/images/posts/2014-07-09/Multi_site_Munki.pdf)

## Managing Macs with Puppet (Penn State MacAdmins, 2013)

{% youtube GqerWmKU1Js 420 315 %}

I spoke about why we chose to use Puppet at pebble.it, how it differs from competing solutions, and how we have utilised it in conjunction with Facter to dynamically configure our machines and gain visibility into the Macs we looked after. [(pdf)](/images/posts/2013-05-24/Managing_Macs_with_Puppet.pdf)
