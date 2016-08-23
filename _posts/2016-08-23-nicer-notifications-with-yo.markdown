---
title: Nicer notifications with Yo
date: 2016-08-23T15:35:50+01:00
layout: post
categories:
  - Yo
  - Scripting
---
Have you ever wished you could let your users know about something without completely taking over their screen with Munki or jamfhelper? Perhaps something that would respect macOS' Do Not Disturb settings? Then Shea Craig's Yo is what you need.

The first thing you're going to need is the Yo installer - you can grab that from [https://github.com/sheagcraig/yo/releases](https://github.com/sheagcraig/yo/releases).

It will drop `Yo.app` into ``/Applications/Utilities`` - but don't go thinking you can just double click on it. Well, you can but you won't have much fun with it. Let's send it a basic notification. Open up `Terminal.app` and run:

``` bash
$ /Applications/Utilities/yo.app/Contents/MacOS/yo --title "You are lovely" --info "I mean it, you look really lovely today"
```

{% img center /images/posts/2016-08-23/Simple_Notification.gif %}

So let's say you would like a button that takes your users to a webpage that gives them more information on their loveliness:

``` bash
$ /Applications/Utilities/yo.app/Contents/MacOS/yo --title "You are lovely" --info "I mean it, you look really lovely today" --action-btn "Do I?" --action-path "https://www.youtube.com/watch?v=vUSzL2leaFM"
```

{% img center /images/posts/2016-08-23/Nicer_notification.gif %}

So that's all there is to using Yo to send notifications to your users. Next time, we'll look at using this for something more useful to Mac admins.
