---
categories:
  - OS X
  - Deployment
  - Casper
  - Munki
comments: true
date: "2013-01-13T00:00:00Z"
title: Casper Vs Munki
---

Next up in the battle of Casper vs the rest of the Mac admin toolset looking to reign supreme in the contest of software installation is Munki.

## Setup

The setup process for a Munki server can seem to be very daunting at first if you've not configured a web server before. If you are happy setting one up, it's the easiest server install you'll ever do! Munki's requirement of just a basic web server means it can run on literally anything (although Casper will also run on anything you're likely to use - I've had both running on Windows boxes for example).

The setup of a Casper server can be quite involved, but chances are if you don't know what you're doing, it's already been done for you during your jump start.

Winner: Casper - if you've paid for the Casper Suite, you're ready to go after your jump start (in theory!). That being said, there are people who can configure Munki for you if you need it ([shameless plug for my employers here!](http://pebbleit.com))

## Getting software into the system

A streamlined workflow for Munki takes a little setup. Our Munki repository lives on an Ubuntu box, with the actual repo being shared out via SMB. This could just as easily be configured on a Windows server or an OS X server if you still have them in your server room.

With the sharepoint set up, I can just mount the repo and then run munkiimport to get the software into Munki. Yes, a lot of people will be put off with having to use a command line interface - that's something all Mac admins will need to get over at some point in their career, it might as well be now!

Casper's method of getting software into the system is simple, but incredibly long winded. You seem to be expected to repackage nearly everything, which is a major pain in the ass. Your JAMF rep will point you towards the pre-made templates in Composer - ironically, most of the apps listed in there, shouldn't need repackaging in the first place as they're either distributed in reasonable packages (like Office) or have tools available to make a package (like Creative Suite). Once you've got the package, it's super simple to get the package into Casper - crack open Casper Admin and drag the package into it. You need to then make a policy which somehow installs the software (more on that in the next section).

Winner: Draw. Munki is more work up front, and doesn't have a GUI which will be an issue for some. Casper is really easy to use, but a complete faff every time you need to get new software onto your macs. You shouldn't need to repackage. Ever. Especially for drag and drop app installations.

## Configuration options

The two systems are fairly feature comparable (pre and post flight scripts, ways to limit who gets what software etc), but it's how they present those options to the admin that differentiates them.

Let's take a common example: installing an Office 2011 update. We have the 14.2.5 update that requires the installation to be at 14.2.3 to start off with.
Some might be, others won't for one reason or another.

We've already got the packages in our respective systems - let's start off with Casper. We need to differentiate the macs that need the update first - we'll do this with a smart group. We make a smart group that has Word at version 14.2.3 and apply the policy to that- great, done right? But what about those users that slipped through the net and only have 14.2? So at that point you need to refine your smart group to target a range of versions. You also need to change this _every time there's an update_. If you only have Office to worry about this might not be too much of a problem, but as soon as you get a few more packages to look after, this rapidly becomes tedious.

Lets look at the same scenario Munki. I just need to mark the update as being an update for Office 2011 (this direct relationship between software and delta updates doesn't exist within Casper) and that the update requires a particular version of Office to be installed within it's pkginfo file - two minutes work in a text editor at worst once you know the syntax.

Winner: Munki - the direct relationship between updates and their parent package is invaluable. As ever, Munki is a lot more work up front, but it pays off in a much easier workflow after that.

## Installing software on client machines

By default, this is what a client sees when Munki wants to install something:

{{< figure src="/images/posts/2013-01-13/Munki.png" >}}

And this is what you see with Casper.

{{< figure src="/images/posts/2013-01-13/Blank_Desktop.png" >}}

No, I've not made a mistake. No warning, no option to delay to a more convenient time, nothing. Nada. Zilch. And you better hope that the app isn't running! It's crash time otherwise.

Munki will warn the user when apps you want to update are running, will warn them when a forced install is coming (several times), will let the user know that a reboot will be needed _before_ the software gets installed.

I know that these things can be done with Casper, I had a demo from a nice chap from JAMF during the week showing me all of this (as a side note, kudos to JAMF for reaching out to me following my last post in this). The issue is, I don't particularly want to write a bash script ever time I deploy software to check if the app is running, warn the user etc etc. We spend on average an hour a week updating our Munki repo - I dread to think how long it would take if I had to do that level of scripting for each package.

The one place Casper does excel on the client side is Self Service. The pretty icons and familiar app store look are much easier for end users to use than Munki's optional installs - that being said, optional installs with Munki aren't exactly hard to use.

Winner: Munki - someone at JAMF told me their goal is to make administrators lives easier. Unfortunately my goal is to make my client's mac experience as awesome as possible, and random reboots with only five minute warnings aren't exactly awesome in my book.

## Reporting

This is the area where Casper excels. Out of the box, the reporting is fantastic. You know who has installed what, when, how many licenses you have left, pretty much anything you need to now is there out of the box.

Munki does have MunkiWebAdmin, but it's an extra install, and can be quite tricky if you're not used to configuring a Django app. It does provide a fair bit of info on what's happening with your Munki-d macs, but nowhere near what you'd get out of Casper. The stats you can get out of Casper are truly immense.

## Auditing Admin actions

This should really come with the post when Casper goes head to head with Puppet, but it affected me in real life a couple of weeks ago, so it can come in today. I came to a Casper install and noticed that the policy that was due to install an Office update had been deleted. Had this happened with our Munki setup, we would just look at the Git history (you are using Git to track your Munki config, right?), see who made the change, find out why, and roll it back if needed.

In this particular instance, I had no idea if it had been done by mistake or on purpose by their internal IT team. I raised this is JAMF this week, and was shown the database log. Whilst this is better than nothing at all, it's still woefully inadequate for a solution that is marketed at the enterprise.

Winner - Munki (or any solution that can have its history tracked effectively)

So for those who stopped keeping count, Munki pips it. On the face of it, depending on your priorities, it's quite a close thing. But as my clients pay my wages, the user experience is of paramount importance to me, so personally, Munki is a clear winner. If my users aren't able to work, they can't earn money. If they can't earn money, they can't pay their IT bill.

Munki offers the greatest flexibility between letting users carry on with their work when there's a not so important update until it's convenient for them to stop and forcing the update (but still warning them appropriately) when it's critical.
