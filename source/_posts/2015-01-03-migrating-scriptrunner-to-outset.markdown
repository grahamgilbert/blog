---
layout: post
title: "Migrating scriptRunner to Outset"
date: 2015-01-03 11:40:41 +0000
comments: true
categories: 
- Python
- scriptRunner
- Outset
---
A while back, Nate Walck wrote [scriptRunner](https://github.com/natewalck/Scripts/blob/master/scriptRunner.py). It's a tool that can run a script either every time a user logs in or just the one time. It has served the test of time, but last year Joe Chilcote released [Outset](https://github.com/chilcote/outset). It has all of the functionality of scriptRunner, but it can also install packages at the Mac's first boot, and run scripts as root at either the first boot or every boot. This comes into it's own when you're trying to do things like skipping the iCloud screens on 10.10 using [Rich Trouton's script](https://derflounder.wordpress.com/2014/10/16/disabling-the-icloud-and-diagnostics-pop-up-windows-in-yosemite/) - this script needs to run after every OS update, so it makes sense to run this every time the Mac boots.

If you've been using scriptRunner and want to move to Outset, you have two options:

* Just move your scripts into the appropriate Outset directories and hope your users don't mind the 'once' scripts running a second time.
* Or pre-populate Outset's 'once' plist so it won't try to run the script it's already run again.

The first option isn't acceptable to me, so this is a script that will populate Outset's plist. One caveat is that Outset requires that your scripts end ``.sh``, ``.rb`` or ``.py``. scriptRunner didn't care about this. When you're moving your scripts into the Outset directory, you will need to ensure your scripts have the correct extension. This script will read the first line and try to work out what kind of script it is if the file doesn't have the right extension.

scriptRunner had a few options you could configure. The first is where your actual scripts live - you will need to edit line 8 of the script to where you put your scriptRunner scripts. Secondly, you might have changed the name of the plist scriptRunner uses - edit line 11 if you did this.

Now all that remains is to put this script into ``/usr/local/outset/login-once``. A [Luggage](https://github.com/unixorn/luggage) Makefile that will do this for you is included in the repository.

I've assumed that you can move your scripts into the new Outset directories using your configuration management tool (Munki, Puppet, Capser, whatever), but if you need a tool that can do this for you (with the previously stated caveat about the file extensions of the scripts), you'll find a script that can be dropped into Outset's firstboot directory.