---
layout: post
title: "The Luggage: An Introduction"
date: 2013-08-09 18:00
comments: true
categories: 
- osx
- packaging
- deployment
---
If you've managed OS X for any amount of time, chances are you've needed to deploy software. And chances also are that you've come across a vendor (I'm looking at you, Adobe) that seems to be incapable of distributing their software in a useful manner. Or maybe you've got your own scripts or software that you need to get installed on the machines that you look after - either way, you're going to want to build a package.

You've got a few options - Iceberg, Packages, Composer, you've even got Package Maker. However, my personal choice is The Luggage. It has a few advantages over the alternatives:

* __It's all text files:__ You're building software distributions, you should be checking the files in to build the packages into version control, such as Git. Text files are ideal for checking into version control.
*  __It's free:__ if it costs nothing, there's no reason it can't be installed on everyone's machine.
* __It's (still) all text files:__ Want to see what will be in the package without any extra work? Crack open the Makefile and you can see straight away what will be in the package.
* __The Luggage has a metric buttload of shortcuts built in:__ it does the hard work, so you don't have to.
* __It's repeatable:__ Have you ever tried to talk someone through a series of windows and buttons to get the same result as you're getting? Every time you run The Luggage, you will get the same result.
* __It's (really, still) all text files:__ It's the most precise tool I've used - you only package exactly what you need, no cruft is left behind.
* __Your workflow is limited only by your imagination:__ Seriously, you can do pretty much anything you can think of. We'll be going through more advanced workflows in future posts, but let's get started with using The Luggage.<!--more-->

## Getting set up

We're going to grab the current version of The Luggage from the git repository. If you don't have git, you can install the Command Line Tools from within [Xcode's](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) preferences if you don't have it. If you don't have Xcode, and the Command Line Tools installed, very little is going to work, so go and install it. It's ok, I'll wait.

{% codeblock lang:bash %}$ cd ~/src
$ git clone https://github.com/unixorn/luggage.git
{% endcodeblock %}

Now we are going to use The Luggage to install itself (oooh, meta). You'll be asked for your password, as it will need to perform some tasks as root.

{% codeblock lang:bash %}$ cd ~/src/luggage
$ make bootstrap_files
{% endcodeblock %}

## Your first Makefile

Now you've got everything set up, we're going to write our first Makefile. We're going to make a package to deploy Nate Walck's awesome [scriptRunner.py](https://github.com/natewalck/Scripts/blob/master/scriptRunner.py). Everything prefaced with a ``$`` should be typed into your Terminal window.

First we're going to grab the repository from GitHub:

``` bash
$ cd ~/src
$ git clone https://github.com/natewalck/Scripts.git natewalck-scripts
```

Now we're going to make a directory to work in for our package and copy scriptRunner.py into it.

``` bash
$ cd ~/src
$ mkdir -p ~/src/scriptRunnerPkg
$ cp ~/src/natewalck-scripts/scriptRunner.py ~/src/scriptRunnerPkg/scriptRunner.py
```

So far so good. Now for the actual Makefile. Create a file in your favourite editor (I recommend [TextMate 2](http://macromates.com/download)), save it as Makefile in ``~/src/scriptRunnerPkg`` and put in the following content:

```
USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make
TITLE=scriptRunnerPkg
REVERSE_DOMAIN=com.grahamgilbert
PAYLOAD=\
	pack-scriptRunner

pack-scriptRunner: l_usr_local_bin
	@sudo ${CP} ./scriptRunner.py ${WORK_D}/usr/local/bin/scriptRunner.py
	@sudo chmod 755 ${WORK_D}/usr/local/bin/scriptRunner.py
	@sudo chown root:wheel ${WORK_D}/usr/local/bin/scriptRunner.py
```

Let's go through this line by line. First, we're overloading a default variable. Back in the day, The Luggage used Package Maker to perform the actual build of the package. This has been deprecated by Apple, replaced with pkgbuild and productbuild. We're just telling The Luggage to go straight ahead and use pkgbuild.

We're then including the main Makefile, which contains all of the pre-built work that we can extend with our own Makefiles. 

``TITLE`` and ``REVERSE_DOMAIN`` are exactly that - the title and reverse domain of the package.

Finally, we're specifying what our payload is going to consist of - in this case, just scriptRunner. Line 8 is using the foundation that The Luggage has already built - installing software into ``/usr/local/bin`` is pretty standard, so we don't need to reinvent the wheel here - we just need to tell The Luggage what to do with the one file we're installing, it will work out the rest.

### An important note on Makefiles
Makefiles are really picky about formatting and spacing - if you get strange errors, make sure you are using tab characters rather than spaces for example. and make sure you've not missed off a colon or a back-slash anywhere.

## Prepare the build!
We're ready to build. Let's do it. No need to run this as sudo, The Luggage will ask for your password if it needs it.

``` bash
$ cd ~/src/scriptRunnerPkg
make pkg
```

If everything has gone well, some text will scroll into your Terminal window and you'll be left with a package sitting in ``~/src/scriptRunnerPkg``.

That's all well and good, but we need a LaunchAgent to run the script when someone logs in. Save the following in ``~/src/scriptRunnerPkg`` and name it ``com.grahamgilbert.scriptrunner.plist``.

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.grahamgilbert.scriptrunner</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/scriptRunner.py</string>
		<string>--once</string>
		<string>/Library/Management/scriptRunner/once</string>
		<string>--every</string>
		<string>/Library/Management/scriptRunner/every</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
```

This will tell scriptRunner.py to run everything in ``/Library/Management/scriptRunner/once`` once per use and everything in ``/Library/Management/scriptRunner/every`` each and every single time the user logs in.

That's nice, but how do we get it into our package? Change the payload section to look like this:

```
PAYLOAD=\
	pack-scriptRunner\
	pack-Library-LaunchAgents-com.grahamgilbert.scriptrunner.plist
```

And now rebuild the package:

``` bash
$ cd ~/src/scriptRunnerPkg
make pkg
```

And that's it! As putting a plist into ``/Library/LaunchAgents`` is as common as a BSOD on Vista, it's built right into The Luggage. A list of most of the available payload additions can be found on [the wiki](https://github.com/unixorn/luggage/wiki) - this isn't everything though. Have a nose through ``/usr/local/share/luggage/luggage.make`` to see everything you can do.

This is obviously a working solution, but there are many manual steps needed if we are sharing our code with others. We'll look into automating some of the steps and deploying a script that scriptRunner.py can work with.