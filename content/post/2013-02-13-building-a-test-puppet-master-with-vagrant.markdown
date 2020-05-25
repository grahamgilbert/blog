---
categories:
- Puppet
- Vagrant
- Code
comments: true
date: "2013-02-13T00:00:00Z"
title: Building a test Puppet Master with Vagrant
---
Puppet is awesome. Until you deploy some code that worked locally, but for some reason didn’t when you put it onto your Puppet Master. Whoops.

So, you need a testing setup. But Puppet can take a while to keep configuring. Which is where [Vagrant](http://www.vagrantup.com) comes in. It it a tool which allows you to build virtual machines automatically (currently only with VirtualBox, but VMWare Fusion support is coming very soon). And the best part (for me, anyway) is that it uses Puppet to configure the VM (Puppet to configure your Puppet Master? All too meta for this time of the morning).

Anyway, that’s enough waffle - the Vagrant configuration is up on my [GitHub](https://github.com/grahamgilbert/vagrant-puppetmaster).

If you are following along with my series on getting started with Puppet on OS X, you can replace the Puppet Labs provided VM with this setup (which would be a good idea, as the Enterprise version is a few versions behind the Open Source version, missing some features when managing Macs).

This testing setup includes:

- A Puppet Master running using the built in web server (fine for testing, not enough poke for a production server)
- Puppet Dashboard (we all love a GUI, right?)
- PuppetDB (this will store data about your nodes, and then hooks into the Dashboard to display it)

To get up and running quickly, you will need:

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](http://downloads.vagrantup.com/)

Once those are installed, cd into the directory where you keep your code (mine lives in ~/Documents/Code), clone the repo and then tell Vagrant to bring the VM up.

	cd ~/Documents/Code
	git clone https://github.com/grahamgilbert/vagrant-puppetmaster.git
	cd vagrant-puppetmaster
	vagrant up
	
If you don’t have the base box Ubuntu box downloaded, Vagrant will pull it down for you and cache the clean VM for you. It will then make a copy, run the script that installs the latest version of Puppet, then run through the Puppet code that will configure the VM to be a Puppet Master for you. Once the VM is running, you can place your modules and manifests in ``puppet/modules`` and ``puppet/manifests``, respectively. The dashboard is accessible at [http://192.168.33.10:3000](http://192.168.33.10:3000).

__This VM is not suitable for production.__ I’ve made several tweaks to the configuration that makes it easier to test your code, but would be a security risk if used on a production server. __Only use this configuration for testing.__ We’re also installing everything onto one VM - you probably want to separate this out into at least two boxes in production, maybe even three if you have a large deployment. Like I said, the idea here is to quickly set up a testing environment that behaves like our production environment.