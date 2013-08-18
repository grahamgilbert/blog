---
layout: post
title: "The Luggage: Further automation"
date: 2013-08-19 11:33
comments: true
categories: 
- osx
- packaging
- deployment
---
As promised in my previous post, today we're going to look at how we can further refine our workflow, with the aim of cutting out as many manual steps as possible (every IT person knows it's not computer that make mistakes, it's the idiots in front of them) and making as much of our code re-usable in other packages.

If you've not read the [previous article](http://grahamgilbert.com/blog/2013/08/09/the-luggage-an-introduction/), you will need to before carrying on with this, unless you're already familiar with The Luggage. If you get stuck, all of the code from this post is [up on Github](https://github.com/grahamgilbert/the-luggage-post-201308).<!--more-->

## Getting scriptRunner

Anyone who uses our Makefile will need a copy of scriptRunner before they can build the script, so we'll cut out that step. Our Makefile becomes:

```
USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make
TITLE=scriptRunnerPkg
REVERSE_DOMAIN=com.grahamgilbert
PAYLOAD=\
	pack-scriptRunner\
	pack-Library-LaunchAgents-com.grahamgilbert.scriptrunner.plist

REPO_URL=https://github.com/natewalck/Scripts.git

pack-scriptRunner: l_usr_local_bin
	@sudo git clone ${REPO_URL} natewalck-scripts
	@sudo ${CP} natewalck-scripts/scriptRunner.py ${WORK_D}/usr/local/bin/scriptRunner.py
	@sudo chmod 755 ${WORK_D}/usr/local/bin/scriptRunner.py
	@sudo chown root:wheel ${WORK_D}/usr/local/bin/scriptRunner.py
	@sudo rm -rf natewalck-scripts
```

All we've done is moved the manual ``git clone`` we were performing on the command line into our Makefile, as this is a step that is required for our package to build successfully. Our aim is to be able to give someone else our code and for them to be able to run ``make pkg`` and get the package out of the other end.

## The real work

Whilst we are now successfully installing ``scriptRunner.py``, it's not actually going to do anything. ``scriptRunner.py`` is passed the paths of two directories - one of scripts it runs every time a user logs in, and another of scripts that it runs once for each user. We specified those directories in the Launch Agent: ``/Library/Management/scriptRunner/once`` and ``/Library/Management/scriptRunner/every``.

This time we're going to build a package that will drop a shortcut to a file server (an ``.afploc``) on each person's desktop as they log in, but do it once only (so they can delete it if they wish). We could do this by modifying the default user template, but this would only affect new users, if there are existing users on the machine they won't get our lovely shortcut. Our package will do the following:

* Install our .afploc file to ``/Library/Management/Desktop_Icons``
* Install our script to copy the .afploc to ``~/Desktop`` when the user logs in

Our Makefile should look like:

```
USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make

TITLE=Desktop_Icons
PACKAGE_NAME=Desktop_Icons
REVERSE_DOMAIN=com.grahamgilbert
PAYLOAD=\
	pack-server\
	pack-script
	
pack-server:
	@sudo mkdir -p ${WORK_D}/Library/Management/Desktop_Icons
	@sudo ${CP} forpeople\ Server.afploc ${WORK_D}/Library/Management/Desktop_Icons/File\ Server.afploc
	@sudo chown -R root:wheel ${WORK_D}/Library/Management/Desktop_Icons
	@sudo chmod -R 755 ${WORK_D}/Library/Management/Desktop_Icons
	
pack-script:
	@sudo mkdir -p ${WORK_D}/Library/Management/scriptRunner/once
	@sudo ${CP} forpeople_Desktop_Icons_20130729 ${WORK_D}/Library/Management/scriptRunner/once/Desktop_Icons_201308
	@sudo chown root:wheel ${WORK_D}/Library/Management/scriptRunner/once/Desktop_Icons_201308
	@sudo chmod 755 ${WORK_D}/Library/Management/scriptRunner/once/Desktop_Icons_201308
```

And the script that does the work will look like:

``` bash Desktop_Icons_201308
#!/bin/bash
if [ -e ~/Desktop/File\ Server.afploc ]
    then
    rm -f ~/Desktop/File\ Server.afploc
fi
cp /Library/Management/Desktop_Icons/File\ Server.afploc ~/Desktop/File\ Server.afploc
```

The script is pretty simple - if the shortcut already exists (maybe they've got a previous version pointing to an old server) it gets removed, and then a new one is copied onto the desktop. I've dated the script as scriptRunner only stores the name of the script to know what it's run - if you replace the script with an updated version but keep the same name, it won't run again (obviously this only applies to scripts that are in the 'once' directory).

Great, it works. But what happens if you want to put another script on the machine to run with scriptRunner? Or maybe you want some more icons - you're about to do a lot of copying and pasting. Wouldn't it be great if we could store the parts that are creating directories and performing common operations in a shared place so multiple Makefiles could use them?

Enter ``/usr/local/share/luggage/luggage.local`` .

When you run ``make pkg``, The Luggage will check for the existence of ``/usr/local/share/luggage/luggage.local``, and use any additions you've put in there. We're definitely going to be putting scripts into ``/Library/Management/scriptRunner/once`` and ``/Library/Management/scriptRunner/every``quite often, so we should automate this.

Here's what my ``luggage.local`` file looks like:

```
l_Library_Management: l_Library
	@sudo mkdir -p ${WORK_D}/Library/Management
	@sudo chown root:wheel ${WORK_D}/Library/Management
	@sudo chmod 755 ${WORK_D}/Library/Management

l_Library_Management_scriptRunner: l_Library_Management
	@sudo mkdir -p ${WORK_D}/Library/Management/scriptRunner
	@sudo chown root:wheel ${WORK_D}/Library/Management/scriptRunner
	@sudo chmod 755 ${WORK_D}/Library/Management/scriptRunner

l_Library_Management_scriptRunner_once: l_Library_Management_scriptRunner
	@sudo mkdir -p ${WORK_D}/Library/Management/scriptRunner/once
	@sudo chown root:wheel ${WORK_D}/Library/Management/scriptRunner/once
	@sudo chmod 755 ${WORK_D}/Library/Management/scriptRunner/once
	
l_Library_Management_scriptRunner_every: l_Library_Management_scriptRunner
	@sudo mkdir -p ${WORK_D}/Library/Management/scriptRunner/every
	@sudo chown root:wheel ${WORK_D}/Library/Management/scriptRunner/every
	@sudo chmod 755 ${WORK_D}/Library/Management/scriptRunner/every

pack-Library-Management-scriptRunner-once-%: % l_Library_Management_scriptRunner_once
	@sudo ${INSTALL} -m 755 -g wheel -o root "${<}" ${WORK_D}/Library/Management/scriptRunner/once
	
pack-Library-Management-scriptRunner-every-%: % l_Library_Management_scriptRunner_every
	@sudo ${INSTALL} -m 755 -g wheel -o root "${<}" ${WORK_D}/Library/Management/scriptRunner/every
```

The first few parts should be pretty obvious to you - we're just making some directories and setting ownership and permissions. The last two sections are of more interest. We're using the ``INSTALL`` variable, which is set to ``/usr/bin/install`` in ``luggage.make`` to move a file and set ownership and permissions. We're using the same technique as we used last time to install the Launch Agent. This means that our Makefile can become:

```
USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make

TITLE=Desktop_Icons
PACKAGE_NAME=Desktop_Icons
REVERSE_DOMAIN=com.grahamgilbert
PAYLOAD=\
	pack-server\
	pack-Library-Management-scriptRunner-once-Desktop_Icons_201308
	
pack-server:
	@sudo mkdir -p ${WORK_D}/Library/Management/Desktop_Icons
	@sudo ${CP} File\ Server.afploc ${WORK_D}/Library/Management/Desktop_Icons/File\ Server.afploc
	@sudo chown root:wheel ${WORK_D}/Library/Management/Desktop_Icons/File\ Server.afploc
	@sudo chmod 644 ${WORK_D}/Library/Management/Desktop_Icons/File\ Server.afploc
```

So we're not only cutting out cruft from our Makefile for this package, but it makes future packages much faster to create, eliminating the problem between the keyboard and chair. You could (should!) even put your ``luggage.local`` file under source control (mine is [on my Github account](https://github.com/grahamgilbert/luggage_local)), so your changes are tracked, and you can collaborate with your colleagues .

You'll notice there is still the section for copying the .afploc. You have two choices here: maybe this is the only time you're ever going to install a file in this directory, in which case this is perfectly fine to leave in the Makefile. However, if you are going to be putting lots of files here, as we are with ``/Library/Management/scriptRunner``, you might want to move this into your ``luggage.local`` file so it is available across all of your Makefiles. You homework, should you choose to accept it, is to generalise that section so it can be reused and move it to ``luggage.local``.