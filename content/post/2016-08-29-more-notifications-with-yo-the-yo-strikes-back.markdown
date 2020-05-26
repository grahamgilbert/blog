---
categories:
- Yo
- Scripting
date: "2016-08-29T22:04:24Z"
title: 'More notifications with Yo: The Yo Strikes Back'
---
Last time, we took our first look at the fantastic Yo. This time, we're going to o something useful - we're going to open an item up in Managed Software Centre.

Let's build our command to show the notification. Note that InstallElCap is the name of the relevent item in Munki. You could for example, replace it with `munki://detail-GoogleChrome`.

``` bash
$ /Applications/Utilities/yo.app/Contents/MacOS/yo --title "Update Required" --info "Your operating system is out of date. Please upgrade ASAP." --action-btn "More Info" --action-path "munki://detail-InstallElCap"
```

{{< figure class="center" src="/images/posts/2016-08-29/Update_Required.gif" >}}
<!--more-->
{{< figure class="center" src="/images/posts/2016-08-29/Update_Notifier.gif" >}}

You want to schedule this you say? Looks like we're going to need a LaunchAgent for that. And let's do something useful - we would like our users to install 10.11 via Munki, but don't want to make it a managed install as they wouldn't be able to install anything else until they've taken the time to install it.

Let's build our directory structure first. I'm going to put the script we'll call in `/opt/grahamgilbert/bin`, but you can put it anywhere you like - just remember to edit all the paths accordingly.

``` bash
# move into the directory we keep our source code
$ cd ~/src
# the project dir
$ mkdir updatenotifier
$ cd updatenotifier
$ mkdir -p payload/opt/grahamgilbert/bin
$ mkdir -p payload/Library/LaunchAgents
```

Now we've got our directory structure, create a file at `payload/grahamgilbert/bin/updatenotifier` with the following content

``` bash payload/grahamgilbert/bin/updatenotifier
#!/bin/bash

/Applications/Utilities/yo.app/Contents/MacOS/yo --title "Update Required" --info "Your operating system is out of date. Please upgrade ASAP." --action-btn "More Info" --action-path "munki://detail-InstallElCap"
```

Let's make it executable

``` bash
$ chmod 755 payload/opt/grahamgilbert/bin/updatenotifier
```

And for our launchagent, add the following at `payload/Library/LaunchAgents/com.grahamgilbert.updatenotifier.plist`

``` xml payload/Library/LaunchAgents/com.grahamgilbert.updatenotifier.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.grahamgilbert.updatenotifier</string>
    <key>Program</key>
    <string>/opt/grahamgilbert/bin/updatenotifier</string>
    <key>RunAtLoad</key>
    <true/>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>
</dict>
</plist>
```

And finally, let's build the package

``` bash
$ pkgbuild --root payload --identifier com.grahamgilbert.updatenotifier --version 1.0.0 ~/Desktop/UpdateNotifier.pkg
```

Now you've got a notification that pops up once an hour, on the hour that lets people know they should upgrade. Where could we improve on this? We could only bug them once a day as this is going to get incredibly annoying. We should also target those who need to upgrade. We also probably want to put our corporate logo on the pop up so our users know it came from us - well, guess what's coming in the next couple of parts?
