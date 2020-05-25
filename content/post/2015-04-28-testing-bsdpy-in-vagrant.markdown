---
categories:
- Docker
- Deployment
- OS X
- Vagrant
comments: true
date: "2015-04-28T16:10:07Z"
title: Testing BSDPy in Vagrant
---

Last time, we looked at how to spin up a Docker host and run BSDPy on it. That's great for production, but might be a bit of a faff to do every time you want to test your NBI at home.

Inspired by [Dr Graham R Pugh](https://grpugh.wordpress.com/2015/04/28/a-test-docker-bsdpy-environment/), here's my Vagrant setup for this.

You will need:

* [Vagrant](https://www.vagrantup.com/)
* Either [VirtualBox](https://www.virtualbox.org/) or [VMware Fusion](http://www.vmware.com/uk/products/fusion) (if you use Fusion with Vagrant, you will need to purchase the [VMware plugin](http://www.vagrantup.com/vmware) - this will allow you to create OS X Vagrantboxes as well as enjoy the much greater performance of VMware, but that's another post)
* Xcode, or at the very least the command line tools from Xcode so you have git available.
* Something to NetBoot - either a physical Mac or a VM in VMware Fusion. A VM configured as per [Rich Trouton's post](https://derflounder.wordpress.com/2013/01/23/building-mac-test-environments-with-vmware-fusion-netboot-and-deploystudio/) will do nicely.

Get all of that installed and you're ready to go. Next we need to get the Vagrantfile:

``` bash
$ git clone https://github.com/grahamgilbert/docker-vagrant.git
```

You will obviously need an NBI - I've [covered how to use AutoNBI before](http://grahamgilbert.com/blog/2015/04/12/building-custom-netinstalls-with-autonbi/), or you could use an existing one. Just make sure you've edited ``NBImageInfo.plist`` to make ``enabled`` be ``true`` and that the Mac (or VM) you're NetBooting isn't in ``DisabledSystemIdentifiers`` (I leave this as an empty ``<array />``). Put your NBI in the ``nbi`` directory.

Now there's one thing left to do:

```bash
$ cd docker-vagrant
$ vagrant up
```

Give it 20 seconds to finish booting and you will see your NBI in the startup pane of your Mac.
