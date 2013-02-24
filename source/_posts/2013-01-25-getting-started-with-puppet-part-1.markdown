---
layout: post
title: "Getting started with Puppet on OS X (part 1)"
date: 2013-01-25 21:22
comments: true
categories: 
- OS X
- Puppet
---
When I was first getting started, the first hurdle I had to get over was trying to work out how it would apply to what I do - manage Macs. There are plenty of resources on managing servers with Puppet, but precious little on using Puppet with OS X - so, here's how to get started with Puppet.
<!-- more -->
First off, grab yourself the Puppet Enterprise demo VM from the [Puppet Labs](http://puppetlabs.com) site - setting up your own Puppet Master is beyond the scope of these articles.

You will also need either a Mac running OS X 10.8 you don't mind (possibly) nuking, or preferably a virtual machine, so you can reset it easily.

I'm using VMWare Fusion here - please translate the commands to whatever virtualisation app you're using.

##Some setup on the Puppet Master
There are a couple of things we need to do to the Puppet Master before we get stuck in with configuring our Mac client. First, change the networking settings so that it appears directly on your network. The default for the VMWare VM is NAT - this won't work for us. Now you can boot it up and SSH into it - if you wait for a minute or two, the IP address of the VM will be displayed on the screen.

The VM you've downloaded is Puppet Enterprise - this is the paid for version of Puppet, that ships pre-configured. We use the open source version, which requires some assembly on the server end (which I will hopefully cover one day). As it's Puppet Enterprise, it comes with the Dashboard all ready to use - we won't be using it here, so don't worry about it. All we want is the IP address.

{% img center /images/posts/2013-01-25/Learning_Puppet_VM__(PE_2.7.0).png  %}

So, let's get into the box:

	ssh root@192.168.3.149
	
The password will be _puppet_

As I mentioned above, being Puppet Enterprise, there are a few differences - the biggest one as far as we're concerned is that the actual Puppet files are in a different location - we'll create a symlink to the "normal" place for Puppet Open Source:

	ln -s /etc/puppetlabs/puppet /etc/puppet

This is optional, but I recommend it, as I will be referring to all paths on the Puppet Master based in this symlink being in place.

Now, onto the Mac - first things first, get SSH turned on - open System Preferences -> Sharing and check Remote Login. Once again, not essential, but it will make your life much easier.

In the real world, you would set up a DNS entry for your Puppet Master - it's likely you won't want to do this when you're just testing out, so let's fake it. Either SSH into your Mac, or just open terminal and issue:

	sudo nano /etc/hosts

You can of course, use whatever text editor you want to - if you've not used nano before, here's a one line crash course: ctrl + O writes the file (you can change the name or just press return and confirm you want to overwrite the file) and ctrl + x to exit. There are more functions of course, but this will get you started enough for this article.

Scroll down to the bottom and put in an entry for your Puppet server's IP address:

{% img center /images/posts/2013-01-25/host_edit.png  %}

Still with me? Good, it's time to install Puppet and Facter. Head on over to [the Puppet Labs download](http://downloads.puppetlabs.com/mac) page and get the latest versions of Puppet and Facter (3.0.2 and 1.6.17 respectively) and install them on your test Mac. Or if you're still SSH'ed into the Mac, you can run this command (which will download and install both Puppet and Facter).

	curl -s https://raw.github.com/grahamgilbert/macscripts/master/Puppet-Install/install_puppet.py | sudo python
	
Cushty, Puppet and Facter are installed. Puppet won't do much though until we write it's configuration file. I'm going to call the Mac puppetclient here.  Pop ``sudo nano /etc/puppet/puppet.conf`` in the Mac's termainl window and paste in the following and save it:
{% codeblock %}
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
#rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates

[master]
# These are needed when the puppet master is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

[agent]
##This is the name of our server
server=puppet
##This is where we specify the name of our client
certname=puppetclient
report=true
pluginsync=true
{% endcodeblock %}

We're now ready to get our client talking to the server. Make sure you've got SSH sessions open to both the client and server, as we'll need to work on both.

On the Mac:

	sudo puppet agent --server puppet --waitforcert 60 --test --group 0
	
And on the Puppet Master we want to list all of the certificates waiting to be signed:
	
	puppet cert --list
	
Once you see your puppetclient's certificate waiting to be signed, sign it on the Master with:

	puppet cert --sign puppetclient
	
After a few seconds you will then see loads of output scrolling along. This is Puppet starting to work it's magic - although Puppet won't do anything yet, as you've not described any configuration for the client - yet. We'll do that next time. 

Apologies for the slightly boring post, but you've done the hard part now, it's all good from here!

[Onwards to part 2!](/blog/2013/01/27/getting-started-with-puppet-on-os-x-part-2/)