---
date: '2012-01-01 20:23:03'
layout: post
slug: web-server-on-linode-part-1
status: publish
title: "Web server on Linode part 1"
wordpress_id: '47'
comments: true
tags:
- apache
- linode
- ubuntu

categories:
- Apache
- Ubuntu
---

Recently, I was tasked with moving a client's web server from a box in their office, to something a little more robust when they put something up there that caused the server to go nuts (30 mb/s nuts!).

The main goals were:

  * Fast, scalable web server
  * Multiple FTP users for the client's web team to modify the site
  * Integrates with their existing CrashPlan PROe backup system.
  * Use GUI's as much as possible for admin so lower level techs could make changes on the server.


After considering several options, we decided to go with Linode. I've had great success hosting my own site with them, and as we had full access to the box, we could install anything we wanted - including CrashPlan.<!--more-->

So, first things first. Get yourself a Linode account. Start off with the cheapest 512 account and work your way upwards if you need the horsepower. Once you've got your account, pick your data centre, and get your VM up and running. We usually go for Ubuntu 10.04 LTS as you'll find the most support online for that.

Now you've got your Ubuntu Linode up and running, let's get the web server up and running (mostly borrowed from the Linode Library).

It's much easier if you set up an A record for your new VM, so for the purposes of this, we'll call our new VM linode.example.com.

The code-type font is stuff your should be putting into your terminal window, one line at a time (but to be honest, if I have to tell you that, maybe this isn't the right thing to be following...)

Set the hostname  
``` bash
echo "linode.example.com" > /etc/hostname
```

Get everything up to date:  
``` bash
apt-get update
apt-get upgrade
apt-get install php5 apache2 mysql-server
```

Bash in your chosen MySQL root password when you're prompted, and you're done.

That's all you need for the most basic web server, but I'm a Mac admin, I quite like having a GUI if I can, so let's get one installed. I quite like webmin, but it's not quite a straightforward as we'd like.

First install the dependencies:  
``` bash
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl libmd5-perl apt-show-versions libapt-pkg-perl
```

You'll notice there's a failure there, so we'll have to hunt that down ourselves. Grab the latest version from: [http://mirrors.kernel.org/ubuntu/pool/universe/libm/libmd5-perl/](http://mirrors.kernel.org/ubuntu/pool/universe/libm/libmd5-perl/)  

``` bash
cd /tmp
wget http://mirrors.kernel.org/ubuntu/pool/universe/libm/libmd5-perl/libmd5-perl_2.03-1_all.deb
dpkg -i libmd5-perl_2.03-1_all.deb
```


Now to grab the latest version of Webmin:
``` bash
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.570_all.deb
dpkg -i webmin_1.570_all.deb
```

Now you should be able to log into webmin with your root username and password at https://linode.example.com:10000

I'm not going to tell you how to set up Apache - there's plenty enough on the internet. It's easy with Webmin, the Apache defaults are reasonably sensible. Just make a directory for your web files, and point a new virtual host at the directory. If you get stuck, a good tutorial can be found at [http://doxfer.webmin.com/Webmin/Name-BasedVirtualHosting](http://doxfer.webmin.com/Webmin/Name-BasedVirtualHosting)

We're nearly done with this part, just a little housekeeping to do. First, a little cleaning up of the MySQL install. Accept the defaults that this script offers:
``` bash
mysql_secure_installation
```

If you're going to be running something like Wordpress, chances are you're going to want your server to send emails.
``` bash
apt-get install exim4
dpkg-reconfigure exim4-config
```

In the configuration wizard, choose Internet Site for the first option, bash in your Linode's hostname (it should already be there - if it's not check you've set the hostname correctly), and make sure that your server will only accept SMTP connections from itself by putting 127.0.0.1 in the next box. In the box asking which domains to accept relays for, enter your Linode's hostname and localhost. Leave the relay domains and relay machines fields blank, and select No when asked about keeping DNS queries down. On the next question on how to store incoming mail, choose whatever you want as you won't be getting any incoming mail here. Finally, accept the default "non-split" part for how to store the configuration file.

For a little security through obscurity, I like to change the port that webmin listens on as well. Log in, go to Webmin -> Webmin Configuration -> Ports and Addresses, and change the listening port to something of your choosing. 

Whilst you're there, you might want to change the port that SSH is on as well. In Webmin, you'll want to be looking at Servers -> SSH Server -> Networking

Finally, I like to disable the root user. First add your own user (give the user a password etc), then add them to the admin group (the user's in this group are automatically added to sudoers).
``` bash
adduser myuser
adduser myuser admin
```

Now log in as your new user and make sure you can sudo - once that's working, you can disable the root user:
``` bash
sudo passwd -l root
```

Assuming everything is working up to this point, change the DNS for your site to point to your new Linode, sit back and congratulate yourself for giving yourself one less physical box to worry about.

You've now got a basic webserver up and running on Linode with a GUI to manage the server. Next time, we'll go over setting up an FTP server with virtual users (with a GUI!), and backing up the server with CrashPlan PROe, including performing a full dump of the mysql databases every night so they're backed up properly.



