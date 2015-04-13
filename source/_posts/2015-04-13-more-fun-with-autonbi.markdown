---
layout: post
title: "More fun with AutoNBI"
date: 2015-04-13 08:05:53 +0100
comments: true
categories: 
- NetInstall
- Python
---

Last time we saw our heroes, there was the unfuffilled promise of making small NetInstall sets. Now is the time to deliver on that promise. We're going to make a small NetInstall that will open up Terminal.app.

If you've not read the [previous post](http://grahamgilbert.com/blog/2015/04/12/building-custom-netinstalls-with-autonbi/) (and have got AutoNBI), go and do it now. I'll wait. All done? <!--more-->

## Previously on 24

{% img /images/posts/2015-04-13/jack.gif %}

As mentioned in the previous post, we're aiming to have a small NetInstall set. Once you've made your NetInstall, open up ``NetInstall.dmg`` - you'll see a ``Packages`` directory. This is where the majority of the bulk in a NetInstall lives - the packages it actually installs. There is also a hidden ``BaseSystem.dmg`` which is what will load when your NetBoot the machine.

## I'm bored, can we make something please?

As I mentioned above, we're going to make a simple NetInstall that will open up a Terminal window. To do that, we're going to leverage something that Apple kindly left in the image for us - ``rc.imaging``. A bit of background - in ``/etc`` you'll find a series of ``rc.*`` files. One of those in a NetInstall is ``rc.install``, which will look for an ``rc.imaging`` file in a few places - one of those is ``/System/Installation/Packages/Extras`` - conveniently a location that Pepijn has made AutoNBI able to work with.

Somewhere on your Mac, make a directory called ``Packages`` and then inside that, make a directory called ``Extras``. Inside that directory we're going to create a file called ``rc.imaging`` with the following contents:

{% codeblock lang:bash Packages/Extras/rc.imaging %}
#!/bin/bash

/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal

/sbin/reboot
{% endcodeblock %}

And make sure it's executable:

``` bash
$ sudo chmod 755 Packages/Extras/rc.imaging
$ sudo chown root:wheel Packages/Extras/rc.imaging
```

And now to make the NetInstall:

```bash
$ sudo ./AutoNBI.py -s /Applications/Install\ OS\ X\ Yosemite.app -f Packages -d ~/Desktop -n MyNetInstall -e
```

The only change from last time is the ``-f`` option - this is the path to your ``Packages`` directory. I created my Packages directory in the same directory as AutoNBI.py - adjust the path if you made yours somewhere else.

{% img /images/posts/2015-04-13/netboot.png %}

You should now be able to boot off your tiny NBI (mine was 574MB) and have a bit of an explore. You'll notice that quite a bit is missing to achieve this tiny size - fortunately Pepijn has been working on getting Ruby and Python included in BaseSystem.dmg, so you have more scripting options when booted.
