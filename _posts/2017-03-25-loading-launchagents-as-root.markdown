---
title: Loading LaunchAgents as root
date: 2017-03-25T19:03:19-07:00
categories:
 - Bash
 - Python
---

There are times when you will need to load a LaunchAgent when a script is running as root - when you are running a postinstall script from a package or when you are loading the LaunchAgent via your management tool of choice (Puppet, Munki, Jamf Pro), for example.

All of these example are assuming you have a LaunchAgent at `/Library/LaunchAgents/com.company.example.plist`.

## Loading a LaunchAgent

``` bash launchagent_load.sh
#!/bin/bash

# get console UID
consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`

/bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.company.example.plist
```

``` python launchagent_load.py
#!/usr/bin/python

from pwd import getpwnam
import subprocess
import sys
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]

if username is None:
    # Exit if there isn't anyone logged in
    sys.exit()

uid = getpwnam(username).pw_uid

subprocess.call(['/bin/launchctl', 'bootstrap', 'gui/{}'.format(uid), '/Library/LaunchAgents/com.company.example.plist'])
```

## Unloading a LaunchAgent

``` bash launchagent_unload.sh
#!/bin/bash

# get console UID
consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`

/bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.company.example.plist
```

``` python launchagent_unload.py
#!/usr/bin/python

from pwd import getpwnam
import subprocess
import sys
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]

if username is None:
    # Exit if there isn't anyone logged in
    sys.exit()

uid = getpwnam(username).pw_uid

subprocess.call(['/bin/launchctl', 'bootout', 'gui/{}'.format(uid), '/Library/LaunchAgents/com.company.example.plist'])
```

The Python version may look more complicated, but is slightly more robust as it is retrieving the current username using Apple's frameworks and I have also allowed for the script not to fail if there isn't a user logged in.
