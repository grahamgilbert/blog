---
layout: post
title: "Creating an OS X base box for Vagrant with Packer"
date: 2013-08-23 11:30
comments: true
categories: 
- Vagrant
- OS X
- VMWare
- Packer
---

A while ago, the chaps over at the [Vagrant](http://www.vagrantup.com/) project have recently released a [plugin to let Vagrant work with VMWare Fusion](http://www.vagrantup.com/vmware) - this means we can finally use Vagrant to provision OS X VMs. 

Why is this a good thing? Do you NetBoot VMWare to test your builds? Or maybe you still have that test Mac on your desk to test your builds. Either way, it's going to be several minutes to restore an image, even if you're thin imaging. With the VM already on your machine, you're ready to go in seconds. Another bonus is that Vagrant isn't only limited to OS X virtual machines - for example, I have a Vagrant configuration that spins up an Ubuntu box configured as a Munki server, with a copy of my repository on an external drive. This allows me to test deployments from anywhere, with everything local to my Mac (have you ever tried testing a Final Cut Studio package from home? 48GB takes a while to download.). I'll go into more detail on this setup in a future post, but for now here's how to get a Mac base box into Vagrant.<!-- more -->

##Pre-requisites

* [Install OS X Mountain Lion.app from the App Store](https://itunes.apple.com/gb/app/os-x-mountain-lion/id537386512?mt=12)
* [VMWare Fusion](http://www.vmware.com/products/fusion/overview.html)
* [Vagrant](http://downloads.vagrantup.com/) (this was written using Vagrant 1.2.7)
* [Vagrant VMWare plugin](http://www.vagrantup.com/vmware)
* [Packer](http://www.packer.io/downloads.html) (I'm using Packer 0.3.1)
* Git (Install the Command Line Tools from within [Xcode's](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) preferences if you don't have it).

##Get set up with Packer

Before we install Packer, you're going to need to download it. No, really, you need it.

Assuming you've downloaded it to ``~/Downloads``, extract the zip file so you will be left with something like this: ``~/Downloads/0.3.1_darwin_amd``. Everything prefaced with a ``$`` should be entered in your terminal.

``` bash
$ sudo mv ~/Downloads/0.3.1_darwin_amd64 /usr/local/packer
$ sudo chown $USER /usr/local/packer
```

You now have a choice: you can refer to the ``packer`` binary by it's full path every time (``/usr/local/packer/packer``), or you can modify your path. The next step is entirely optional, but I highly recommend it. You need to edit ``~/.profile``.

``` bash
$ nano ~/.profile
```

And add this line to the file, then save it (``CTRL-O`` then ``CTRL-X``):

``` bash
export PATH="/usr/local/packer:$PATH"
```

And then quit and re-open Terminal.app.

## Templates
Packer uses template files to define how it should build the VM for you. Fortunately, [Tim Sutton](http://macops.ca) has created a template file that can be used with Packer.

``` bash
# I keep other people's code in ~/src/Others
$ git clone https://github.com/timsutton/osx-vm-templates.git ~/src/Others
```

There are a couple of prep steps we need to do before we can instruct Packer to make our box. First off it's going to need installation media. There is a script that will prepare the Install OS X Mountain Lion.app so it can be used with Packer.

```bash
$ cd ~/src/Others/osx-vm-templates
$ sudo prepare_iso/prepare_iso.sh "/Applications/Install OS X Mountain Lion.app" out
```

You'll see some activity in your terminal, and then you'll be given the filename of your installation DMG and the checksum. You'll need these in the next step.

Open up ``packer/template.json`` in your favourite editor. Paste in the checksum you were given in the last step (yours will probably be different from mine), and specify the path to your installation DMG (obviously use the path to your home directory, not mine!). You can also edit the size of the disk, the memory etc in this file.

``` json
"iso_checksum": "14cd20f75c7c0405198fa98006a4442e",
"iso_url": "file:///Users/grahamgilbert/src/Others/osx-vm-templates/out/OSX_InstallESD_10.8.4_12E55.dmg",
```


## Prepare the build!

You're ready to go. This next step will take __AGES__ so go and make a cup of coffee (or tea), as this is going to install OS X, run through the scripts to install the bits Vagrant needs (like Puppet), then make a Vagrant base box.

```bash
# Make sure we're in the right directory
$ cd ~/src/Others/osx-vm-templates/packer
$ packer build template.json
```

After you hit return, VMware will open up and OS X will start installing. Once everything is done, and Packer tells you it's done in your terminal window, you just need to add it to Vagrant and then you're ready to use it.

##Adding the VM to Vagrant
 
```bash
$ vagrant box add osx ~/src/Others/osx-vm-templates/packer/packer_vmware_vmware.box
```

## Using the VM in Vagrant

We're going to make a quick Vagrant configuration using your newly built box.

```bash
$ mkdir -p ~/Desktop/osx_test
$ cd ~/Desktop/osx_test
$ vagrant init osx
```

You're probaly going to want a GUI when it boots, so open up ``~/Desktop/osx_test/Vagrantfile`` in your text editor of choice and find the next section.

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

Unfortunately there isn't any support for OS X in the official Vagrant release (yet), but good old Tim Sutton has sorted that out for us. We're going to clone his repository, switch to the branch with his changes and copy the needed files into the main Vagrant installation. Hopefully his changes will be merged into a future of Vagrant, but for now:

```bash
$ cd ~/src/Others
$ git clone https://github.com/timsutton/vagrant.git timsutton-vagrant
$ cd ~/src/Others/timsutton-vagrant
$ git checkout guest-plugin-osx
$ sudo cp -R ~/src/Others/timsutton-vagrant/plugins/guests/osx /Applications/Vagrant/embedded/gems/gems/vagrant-1.2.7/plugins/guests/osx
```

We're ready to boot the thing now - make it so, number one.

```bash
$ cd ~/Desktop/osx_test
$ vagrant up --provider vmware_fusion
```

You should see VMWare Fusion open if it's not already running and your VM boot after a little while.

## What's next?
You can configure this box with a script, or using Puppet or Chef (can you guess which I'd do?)?