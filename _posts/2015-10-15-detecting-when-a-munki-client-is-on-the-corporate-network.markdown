---
layout: post
title: "Detecting when a Munki client is on the corporate network"
date: 2015-10-15 12:37:34 +0100
comments: true
categories: 
- python
- munki
---

Sometimes it is useful to know whether a Munki client is on your corporate network - you might have a package or script that will only work when able to access an internal resource, or you might just want statistics on which users are accessing your internal infrastructure and external infrastructure.<!-- more -->

The idea is to have your clients attempt to access a URL that they will only have access to when they're on your internal network. This URL should return the following plist when the client accesses it:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>response</key>
    <string>active</string>
</dict>
</plist>
```

## The condition script

You can find the condition script on [my Github](https://github.com/grahamgilbert/munki_conditions/tree/master/on_corp). You should modify [line 11](https://github.com/grahamgilbert/munki_conditions/blob/master/on_corp/on_corp.py#L11) of that script to point to your plist, and you can then distribute it to your clients however you wish (a Makefile for [The Luggage](https://github.com/unixorn/luggage) is in the repo).

When all is running, you will have access to an ``on_corp`` condition for use in your manifests.

``` xml
<key>conditional_items</key>
<array>
    <dict>
      <key>condition</key>
      <string>on_corp == TRUE</string>
      <key>managed_installs</key>
      <array>
          <string>MyOnCorpOnlyPackage</string>
      </array>
    </dict>
 </array>
```
 
Or if your Munki reporting tool supports using data from Conditions (like [Sal](https://github.com/salopensource/sal)!), you could display that infomation in a [plugin](https://github.com/salopensource/grahamgilbert-plugins/tree/master/oncorp).

{% img center /images/posts/2015-10-15/Sal_plugin.png 290 133 %}