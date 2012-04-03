---
date: '2011-12-10 20:45:29'
layout: post
slug: thoughts-on-profile-manager
status: publish
title: Thoughts on Profile Manager
wordpress_id: '40'
tags:
- '10.7'
- lion
- Profile Manager
- server
---

We've been using a 10.7 Server in the office since Lion was released, but it is only now that I'm about to install an all Lion office, so will get the chance to use Profile Manager in a real install. Over the last few months, I've noticed a couple of things:



  * Don't bother using a self signed SSL certificate. Preferences will fail to push seemingly at random without a proper certificate. For what they cost, get over to Godaddy and buy yourself a cheap certificate and save yourself hours of head scratching.



  * On first glance, Profile Manager seems to be lacking load of options that we had in Workgroup Manager. Remember that your can upload your own plists, so we can still set all of the options that we could before. 



  * I've not been able to set Mobility preferences using Profile Manager, so have had to fall back to MCX for this as the client mac steadfastly refuses to use the settings I've set in Profile Manager. If anyone has any ideas about this, I'd love to hear them.



  * If you're using DeployStudio, your can cut out a load of post imaging faffing about with enrolling the mac by using an Enrolment Profile and then using the workflow item in DS to get the client talking to your server.


