---
date: '2012-02-01 17:30:35'
layout: post
slug: making-a-lion-recovery-hd
status: publish
title: Making a Lion Recovery HD
wordpress_id: '57'
tags:
- '10.7'
- lion
- Recovery HD
---

So you've lovingly crafted your never booted image in InstaDMG. It's fully up to date and lovely. And then you try to enable FileVault 2. As you have no Recovery HD, it's not going to happen.

I've tried several methods to get around this, including taking an image of an existing Recovery HD. It worked (ish), but didn't feel right. Then I found this post on [google +](https://plus.google.com/113021614344742332063/posts/8D8FJjps5C6). I've lovingly ripped off the method and put it into a package for deployment with DeployStudio, ARD, or anything else that can take normal packages. [You can download everything from my GitHub](https://github.com/grahamgilbert/Make-Recovery-HD), usage instructions are in the readme.
