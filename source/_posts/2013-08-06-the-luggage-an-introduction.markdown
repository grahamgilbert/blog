---
layout: post
title: "The Luggage: An Introduction"
date: 2013-08-06 18:00
comments: true
categories: 
- osx
- packaging
- deployment
---
If you've managed OS X for any amount of time, chances are you've needed to deploy software. And chances also are that you've come across a vendor (I'm looking at you, Adobe) that seems to be incapable of distrbuting their software in a useful manner. Or maybe you've got your own scripts or software that you need to get installed on the machines that you look after - either way, you're going to want to build a package.

You've got a few options - Iceberg, Packages, Composer, you've even got Package Maker. However, my personal choice is The Luggage. It has a few advantages over the alternatives:

* It's all text files: You're building software distributions, you should be checking the files in to build the packages into version control, such as Git. Text files are ideal for checking into version control.
*  It's free: if it costs nothing, there's no reason it can't be installed on everyone's machine.
* It's (still) all text files: Want to see what will be in the package without any extra work? Crack open the Makefile and you can see straight away what will be in the package.
* The Luggage has a metric buttload of shortcuts built in: it does the hard work, so you don't have to.
* It's (really, still) all text files: It's the most precise tool I've used - you only package exactly what you need, no cruft is left behind.
* Your workflow is limited only by your imagination: Seriously, you can do pretty much anything you can think of. We'll be going through more advanced workflows in future posts, but let's get started with using The Luggage.

## Getting set up

We're going to grab the current version of The Luggage from the git repository. If you don't have git, you can install the Command Line Tools from within [Xcode's](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) preferences if you don't have it.

{% codeblock lang:bash %}$ cd ~/src
$ git clone https://
{% endcodeblock %}

Now we are going to use The Luggage to install itself (oooh, meta).

{% codeblock lang:bash %}$ cd ~/src/luggage
$ make bootstrap_files
{% endcodeblock %}

## Your first Makefile

Now you've got everything set up, we're going to write our first Makefile.

Calling it with a LaunchDaemon - the shortcut.