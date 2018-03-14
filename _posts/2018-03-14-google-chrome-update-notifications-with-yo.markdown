---
title: Google Chrome update notifications with Yo
date: 2018-03-14T12:23:33-07:00
layout: post
categories:
 - Python
 - Yo
 - Google Chrome
 - Security
---
Web browsers are critical to pretty much any organization. For many people, the browser is everything, right down to their email client. Since the browser is probably the most used piece of software, and users are putting all kinds of private information into it, it's vital browsers are kept patched.

Fortunately our default browser is Google Chrome, and Chrome is really good at keeping itself updated. Unfortunately it completely sucks at letting the user know that there is an update to install. I mean really, we're just going to leave it at three tiny lines changing from grey to orange?

_Useless._

## So what are our options?

Like most people, we used our software deployment tool to patch it initially. In our case it was Munki. So the process was we merge in the update into our Munki repo, roughly an hour rolls by and Managed Software Center pops up and asks the user to quit Chrome to update it. All done, right?

Well, not quite. We noticed high numbers of pending updates sitting there in [Sal](https://github.com/salopensource/sal). So your intrepid author took a trip to the help desk to have a listen in on some of the users.

Turns out people are really protective about their tabs. It’s the modern equivalent of not wanting to restart because they will “lose their windows”.

If a user by some random chance find their way to finding Google’s built in update button, Chrome will restart gracefully and preserve their tabs. So we set about working out how we could do this ourselves.

## Won't someone just think of the tabs?

`chrome://restart` has been around for a while, but for obvious reasons doesn’t work anywhere outside of typing it into Chrome’s location bar, which isn’t exactly user friendly.

After various attempts to trigger this Mike Lynn mentioned on MacAdmins Slack that they had found a way to do it - and it wasn’t pretty, but it worked.

It involved (_shudder_) AppleScript.

So, we had a method to restart Chrome and keep our user's tabs safe. We just needed a method to let our users know about it.

## Which version is running?

When Chrome's auto update runs, they actually replace the app bundle from underneath the user. It took me a while (and some help on Slack from Tim Sutton) to work out what was going on. Google places a copy of the binary that is named the same as the version. This means that we can have multiple copies of the app in the same place.

```
ls -la /Applications/Google\ Chrome.app/Contents/Versions/
total 0
drwxr-xr-x@ 4 root  wheel   128B Mar 13 12:43 .
drwxr-xr-x@ 9 root  wheel   288B Mar 12 18:30 ..
drwxr-xr-x  5 root  wheel   160B Mar  5 23:57 65.0.3325.146
drwxr-xr-x  5 root  wheel   160B Mar 12 17:45 65.0.3325.162
```

{% img center /images/posts/2018-03-14/clever_girl.gif %}

Now to work out if there is an update to install, we simply need to read the `Info.plist` in the app bundle (the version that _should_ be there) and compare it with the version that is actually running. If the version in the `Info.plist` is newer than the version running, the user has an update to perform.

## Yo!

I'm a big fan of Shea Craig's Yo. We have our own version that we have branded with our company logo so users know the notification is coming from us - we've used it in the past to let users know our anti-malware tool has cleaned something up, or that they are going to need to update their operating system soon. It's a nice way of giving the user information without getting in their face.

{% img center /images/posts/2018-03-14/chrome_update_notification.png %}

I have packaged up a generalized version of the script and put it on [Github](https://github.com/grahamgilbert/chrome_update_notifier). This script will also only notify the user once for each version so we don't spam them.
