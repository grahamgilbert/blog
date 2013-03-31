---
layout: post
title: "Creating an OS X base box for Vagrant with Veewee"
date: 2013-03-28 11:30
comments: true
published: false
categories: 
- Vagrant
- OS X
- VMWare
---

The chaps over at the [Vagrant](http://www.vagrantup.com/) project have recently released a [plugin to let Vagrant work with VMWare Fusion](http://www.vagrantup.com/vmware) - this means we can finally use Vagrant to provision OS X VMs. This post is largely based on [Gary Larizza's work](http://garylarizza.com/blog/2013/01/20/using-veewee-to-build-os-x-vms/), but has been updated for the latest version of Vagrant.

##Pre-requisites

* [Install OS X Mountain Lion.app from the App Store](https://itunes.apple.com/gb/app/os-x-mountain-lion/id537386512?mt=12)
* [VMWare Fusion](http://www.vmware.com/products/fusion/overview.html)
* [Vagrant](http://downloads.vagrantup.com/) (this was written using Vagrant 1.1.0)
* [Vagrant VMWare plugin](http://www.vagrantup.com/vmware)
* Git (Install the Command Line Tools from within [Xcode's](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) preferences if you don't have it).


##Set up rbenv

Veewee needs a version of Ruby higher than the one that ships with OS X. Thankfully Octopress has a good set of [instructions](http://octopress.org/docs/setup/rbenv/) with getting up and running with rbenv and ruby 1.9.3. As an aside, if you've configured your Mac with Boxen, you already have rbenv and Ruby 1.9.3.

##Get set up with Veewee

First off, we're going to pull down the latest version of Veewee. Lines prefixed with a $ should be entered into your Terminal window:

``` bash
# I keep my code in ~/src, separating out my code, and other people's
$ mkdir -p ~/src/Others
$ cd ~/src/Others

# Pull down the latest Veewee code
$ git clone https://github.com/jedi4ever/veewee.git
$ cd ~/src/Others/veewee
```

Now we've got the latest version of Veewee, we need to let it install it's dependencies.

```bash
# Switch to Ruby 1.9.3
$ rbenv local 1.9.3

# Install Bundler
$ gem install bundler

# Tell Bundler to install everything Veewee needs
$ bundle install
```

This command might take a few minutes to complete. Once you're back at a command prompt, you're ready to move on.

## Prepare the build!

Veewee has templates for building most operating systems that can be used to create a clean VM with the bits Vagrant needs pre-installed (much the same way InstaDMG works). We are going to create a new VM definition from the OSX template:

```bash
# Make sure we're in the right directory
$ cd ~/src/Others/veewee

# Define our VM
$ bundle exec veewee fusion define 'osx-vm' 'OSX'
```

This will create an ``osx-vm`` folder within ``definitions``. You can customise how the VM is created, here, but the defaults are fine for us. The next step is to prepare an installation image for our VM.

```bash
$ cd ~/src/Others/veewee
$ mkdir iso
$ sudo definitions/osx-vm/prepare_veewee_iso/prepare_veewee_iso.sh "/Applications/Install OS X Mountain Lion.app"
```

We're now ready to build the VM:

```bash
$ cd ~/src/Others/veewee
$ bundle exec veewee fusion build osx-vm
```

 This will take some time, as we're installing a whole OS X system. You'll see VMWare open up and the installation process will start - don't touch anything, as the whole process is automated. Once the process is finished, log into the ``vagrant`` user (the password is ``vagrant``) and eject the installation disk and then shut down the VM. Highlight the VM in the list in the Virtual Machine Library in VMWare Fusion and choose Settings. Go to CD/DVD and change the installation DMG to your SuperDrive.

##Getting our VM ready for Vagrant
 
 VMWare Fusion VMs are are just folders with the various parts of the virtual machine inside. We need to do a couple of things to get our VM ready.
 
```bash
# Change to the correct directory - adjust to where VMWare Fusion keeps VMs by default on your system
$ cd ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm
```

Now we need to tell Vagrant what provider to use. Create a file within the osx-vm.vmwarevm directory called ``metadata.json`` with the following contents:

```javascript
{
  "provider": "vmware_fusion"
}
```

We need to remove any files ending .lck.

```bash
$ cd ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm
$ rm -r *.lck
```

Now we need to defragment and shrink the drive:

```bash
$ /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -d ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm/osx-vm.vmdk
$ /Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm/osx-vm.vmdk
```

It's just a case of packaging the VM for Vagrant now.

```bash
$ cd ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm
tar cvzf osx.box ./*
```

## Using the VM in Vagrant

You will now have a file called osx.box within the osx-vm.vmwarevm directory. You will want to move this somewhere else to keep it safe later, but for now, let's just move it to the desktop.

```bash
$ mv ~/Documents/Virtual\ Machines.localized/osx-vm.vmwarevm/osx.box ~/Desktop/osx.box
```

After moving it, you can delete the osx-vm from VMWare Fusion - we don't need it anymore. We'll make a quick Vagrant configuration to use this base box:

```bash
$ mkdir -p ~/Desktop/osx_test
$ cd ~/Desktop/osx_test
$ vagrant init osx
```

An OS X VM doesn't seem to work headless, so you will need to open up the Vagrantfile and find the section that reads

```ruby
# config.vm.provider :virtualbox do |vb|
#   # Don't boot with headless mode
#   vb.gui = true
#
#   # Use VBoxManage to customize the VM. For example to change memory:
#   vb.customize ["modifyvm", :id, "--memory", "1024"]
# end
```
  
  And change it to read
  
```ruby
config.vm.provider :vmware_fusion do |v|
#   # Don't boot with headless mode
   v.gui = true
#
#   # Use VBoxManage to customize the VM. For example to change memory:
#   vb.customize ["modifyvm", :id, "--memory", "1024"]
end
```

You will also need to tell Vagrant where to find the box. Uncomment the config.vm.box_url line and point it to your base box on your desktop. This could just as easily be on a web server so you could share the box with your team.

```ruby
config.vm.box_url = "/Users/grahamgilbert/Desktop/osx.box"
```

We're ready to boot the thing now - make it so, number one.

```bash
$ vagrant up --provider vmware_fusion
```

You should see VMWare Fusion open if it's not already running and your VM boot after a little while.

## What's next?
My next step would be to configure it with Puppet or Chef (can anyone guess what my preference would be?). You could also use whatever script 