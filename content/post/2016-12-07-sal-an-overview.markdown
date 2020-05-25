---
categories:
- Sal
date: "2016-12-07T11:09:39Z"
title: 'Sal: an overview'
---

It's been a long time since I wrote about Sal here (nearly [three years](/blog/2014/01/17/sal-the-munki-puppet/)), so with the release of Sal 3.0, it's time to take another look at it.

## What is Sal?

Sal is a reporting tool for macOS clients that helps you visualise what your clients are up to. It is primarily a reporting tool for [Munki](https://github.com/munki/munki), but it can also ingest data from [Facter](https://docs.puppet.com/facter/latest/) (whether you are using Puppet to manage your Macs or not).

It has the concept of business units, so if you wish to separate your clients out (for example, if you wish to give access to some machines to a sub organisation's IT etc) you are able to do so.

That's the 10000 feet overview, let's take a look at some of it's functionality in more detail.

## The dashboard

{{< figure class="center" src="/images/posts/2016-12-07/01-Dashboard.png" >}}

The first thing you see when you log into Sal is the dashboard. This is where you can get access to a quick overview of your fleet. Each graph, chart, set of buttons is a plugin - this means that each one can be re-ordered and removed - you can even make your own if you need to (more on that another time). Most plugins are clickable - click on the relevent part to show a list of machines it is referring to - and if the plugin supports showing the list (and all of the built in ones do), you can export the list to CSV (since all managers love spreadsheets, right?).<!--more-->

## Machine detail

{{< figure class="center" src="/images/posts/2016-12-07/02-MachineDetail.png" >}}

The machine detail page is where you can take a closer look at one particular machine. It's here you can get the status of each machine's Munki installs, take a look at the machine's Munki conditions and Facts (if you are using Facter), and see if there are any errors or warnings from Munki. Need something that's not included? Read on to find out about plugins.

## Plugins

{{< figure class="center" src="/images/posts/2016-12-07/03-Widgets.png" >}}

Sal is designed to be completely customisable - if you need a specific widget on the dashboard for your organisation, you can write it without forking and having to maintain your own copy of Sal. If there is a widget included you don't need, simply disable it through the GUI - no editing of configuration files needed.

There are three different kinds of widgets:

* Basic widgets - these are what you see on the dashboard. If you need to get a quick overview of your machines, this is the widget for you.
* Reports - these are widgets that take up the whole screen. They give you a deeper dive into one particular aspect of your machines (for example, an overview of the Munki configuration on your machines).
* Machine detail widgets - these allow you to extend the Machine detail page. For example, one of the built in machine detail widgets shows the security status of the machine.

Some of the built in widgets include:

* Operating system version
* Munki version
* Pending third party and Apple updates
* Disk space avaialble
* Uptime
* Gatekeeper, SIP and Encryption status
* More! (22 are included at the time of writing, with more added with every release)

## Search

{{< figure class="center" src="/images/posts/2016-12-07/04-SearchBuild.png" >}}

One of the most important parts of a reporting tool is getting information out of it. One of the strengths of commercial tools is their ability to build complex queries without needing to be a programmer. Sal 3.0 introduces advanced search. Sal's search allows you to build complicated search queries on any of the data points it collects on the machines in your inventories from the GUI. And to keep your manager happy, each search can be exported to a CSV.

### Saved searches

{{< figure class="center" src="/images/posts/2016-12-07/05-SavedSearch.png" >}}

If you have searches your team performs regularly, you can choose to save your search - they are then avaialble for the rest of your team.

## Application inventory

{{< figure class="center" src="/images/posts/2016-12-07/06-AppInventory.png" >}}

Of course, you don't only care about the apps you're telling Munki to install. Sal will track the complete application inventory for all of your machines. Want to know if anyone has been naught and installed Mac Keeper? We've got you covered.

## Things for developers

In a future post, I'll go over things that the more developer-minded people will find interesting:

* API: Sal has a full API which will allow you to integrate it with your existing apps (for example, you may be fed up with updating your asset inventory tool with the specs of each machine - let the robots do it)
* Custom plugins: Each plugin for Sal is written in Python, which allows you to do some incredibly powerful things