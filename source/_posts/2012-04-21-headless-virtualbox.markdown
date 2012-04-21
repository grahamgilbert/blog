---
layout: post
title: "Headless VirtualBox"
date: 2012-04-21 22:06
comments: true
categories: 
- Mac OS X Server
- Vitualisation
---
I recently had a requirement to run an Ununtu machine, but the client had only mac servers, and no budget for additional hardware. The solution turned out to be VirtualBox - we could run it headless and have it start when the mac booted.

First, get your VM set up how you like it and shut it down. I like to move my VMs out of the boot drive, so move the entire ~/VirtualBox VMs directory onto your storage device. 

VirtualBox needs to know where the vm lives now, so remove the original vm you made, then double click the moved vbox file. 

One last step - the launchd item to control the vm. 

I recently had a requirement to run an Ununtu machine, but the client had only mac servers, and no budget for additional hardware. The solution turned out to be VirtualBox - we could run it headless and have it start when the mac booted.

First, get your VM set up how you like it and shut it down. I like to move my VMs out of the boot drive, so move the entire ~/VirtualBox VMs directory onto your storage device. 

VirtualBox needs to know where the vm lives now, so remove the original vm you made, then double click the moved vbox file. 

One last step - the launchd item to control the vm. 

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
  	<key>Label</key>
	  <string>com.yourcompany.mysupervm.plist</string>
	  <key>ProgramArguments</key>
	  <array>
	    <string>/usr/bin/VBoxHeadless</string>
	    <string>-startvm</string>
	    <string>The name of your VM</string>
	  </array>
	<key>KeepAlive</key>
	<true/>
	  <key>UserName</key>
	  <string>admin</string>
	  <key>WorkingDirectory</key>
	  <string>/Volumes/Storage</string>
	  <key>RunAtLoad</key>
	  <true/>
	</dict>
	</plist>
	
Change some "The name of your VM" to what your vm is actually called, change UserName to the admin username on the server, and finally change the WorkingDirectory path to match the location of your VirtualBox VMs directory. 

Save the plist into /Library/LaunchDaemons/ as com.yourcompany.mysupervm.plist (or whatever you want) and chown it to root:wheel

To start the vm, crack open terminal and issue
	
Change some key to the name of the vm, change another key to the admin username on the server, and finally change the path to match the location of your VirtualBox VMs directory. 

Save the plist into /Library/LaunchDeamons/ as com.yourcompany.mysupervm.plist (or whatever you want) and chown it to root:wheel

To start the vm, crack open terminal and bash in:
	sudo launchctl load /Library/LaunchDaemons/com.yourcompany.mysupervm.plist
	
And to stop:
	sudo launchctl unload /Library/LaunchDaemons/com.yourcompany.mysupervm.plist
	
The vm will start at boot, and will continue to run, so to stop it, you need to unload the plist.