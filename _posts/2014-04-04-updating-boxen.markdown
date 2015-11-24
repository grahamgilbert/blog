---
layout: post
title: "Updating Boxen"
date: 2014-04-04 07:54:26 +0100
comments: true
categories: 
- OS X
- Puppet
- Boxen
---
As you might know, I'm a bit of a fan of [Munki and Puppet](https://www.youtube.com/watch?v=GqerWmKU1Js) for managing the Macs I look after. Around a year ago, I really wanted to be able to automate my own setup across my own Macs the same way. I was forever finding that the particular git repository or app wasn't on the Mac I was working on. Then there came the time when I wanted to do a clean install - that was easily a day down the drain there!

## Automate all of the things

Then [Boxen](https://boxen.github.com/) was released - based on Puppet, but targeted at setting up individual's machines. I got on board just over a year ago, and haven't really looked back - manually installing an app on my Mac seems very strange now. I'm not going to cover how to get started with Boxen, as there are [many getting started guides out there](http://lmgtfy.com/?q=getting+started+with+Boxen) (however, [Gary Larizza's](http://garylarizza.com/blog/2013/02/15/puppet-plus-github-equals-laptop-love/) is rather good).

There will come a time when you need to update the core part of Boxen. This happened to me when I clean installed 10.9 on my work laptop - all kinds of shit broke (somehow it managed to survive the upgrade process - go figure). I looked around, but couldn't really find a definitive guide, so here it is (it's shorter than this piece of rambling).

## Ok, stop talking

As Boxen is made by GitHub, updating it is much like updating any other project on there that you've made a fork of.  First we're going to add it as a remote repository:

``` bash
$ cd ~/src/our-boxen
$ git remote add upstream https://github.com/boxen/our-boxen.git
```

Then we're going to fetch the stuff from the upstream repository:

``` bash
$ git fetch upstream
```
Now we're going to merge the updated repository with our own:

``` bash
$ git checkout master
$ git merge upstream/master
```

If you haven't modified any of the core Boxen files (``Puppetfile``, ``Gemfile`` or ``manifests/site.pp`` in my case), you might get away without having to fix any conflicts (you can ignore any in ``Puppetfile.lock`` and ``Gemfile.lock``, we'll deal with those next). I had conflicts as I had previously:

* Been stupid and tried to update Boxen by just changing the Puppet Module and Gem versions
* Edited ``site.pp`` as I didn't want Nginx or node.js installed
* Been dumb and put my custom Puppet modules in the wrong place in my ``Puppetfile``

None of these were particularly arduous to fix, but annoying none the less. If you find you have loads, you might want to run:

``` bash
$ git mergetool
```

The next step is to update your Puppet modules and RubyGems. First delete ``Puppetfile.lock`` and ``Gemfile.lock``. Now go back to your trusty Terminal and:

``` bash
$ bundle install --without development
$ bundle exec librarian-puppet install --clean
```

At this point, you might want to go through the custom modules you've added to your ``Puppetfile`` and update those, although this is by no means required - some apps I've installed through Boxen don't have a built in updater, so Boxen is more convenient than hunting for installers on various vendor's websites. Once your modules are up to date in your ``Puppetfile``,  you're done! You can now get your Mac back to how you like it by issuing the usual:

``` bash
$ boxen
```