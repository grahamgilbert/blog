---
title: Return of the Yo notifications
date: 2016-09-05T08:07:57+01:00
layout: post
categories:
 - Scripting
 - Python
 - Yo
---
[Last time](/blog/2016/08/29/more-notifications-with-yo-the-yo-strikes-back/), took our first steps to notify our users about updates in a slight nicer way. This time we are going to modify our script so that our users are only bugged once a day, and also not promoted to install 10.11 if they're already running it.

Unfortunately for some, whilst this will be possible if we stuck to using bash, it would drive me insane, so we are switching to Python. Don't be scared! Python makes a lot of sense once you get your head around it, and you'll be a much happier mac admin once you leave the 1500 line bash scripts behind. <!-- more -->

First off, let's get to the point we were at last time in python. Replace `payload/opt/grahamgilbert/bin/updatenotifier` with this (remember you can test your script as you're going along by calling the script manually: `$ payload/opt/grahamgilbert/bin/updatenotifier`):

``` python payload/opt/grahamgilbert/bin/updatenotifier
#!/usr/bin/python

import subprocess

def run_yo(title, text, url):
    cmd = [
        '/Applications/Utilities/yo.app/Contents/MacOS/yo',
        '--title',
        title,
        '--info',
        text,
        '--action-btn',
        'More Info',
        '--action-path',
        url
    ]
    subprocess.call(cmd)

def main():

    run_yo(url='munki://detail-InstallElCap',
            title='Operating System Update',
            text='Your Mac is out of date, '\
            'please upgrade ASAP.')

if __name__ == '__main__':
    main()
```

So the first thing we're going to change is adding in a method to track when the user has seen our notification. We're going to use macOS' built in method for storing preferences - whilst not technically a preference, we are storing a value we want to persist across reboots, so a preferences makes perfect sense. Make `payload/opt/grahamgilbert/bin/updatenotifier` look the the code below.

``` python payload/opt/grahamgilbert/bin/updatenotifier
#!/usr/bin/python

import datetime
import subprocess
import time

from Foundation import *

BUNDLE_ID = 'com.grahamgilbert.updatenotifier'

def run_yo(title, text, url):
    cmd = [
        '/Applications/Utilities/yo.app/Contents/MacOS/yo',
        '--title',
        title,
        '--info',
        text,
        '--action-btn',
        'More Info',
        '--action-path',
        url
    ]
    subprocess.call(cmd)

def set_pref(pref_name, pref_value):
    CFPreferencesSetAppValue(pref_name, pref_value, BUNDLE_ID)
    CFPreferencesAppSynchronize(BUNDLE_ID)

def pref(pref_name):
    default_prefs = {
        # 'last_shown' : NSDate.new(),
    }
    pref_value = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
    if pref_value == None:
        pref_value = default_prefs.get(pref_name)
        # we're using a default value. We'll write it out to
        # /Library/Preferences/<BUNDLE_ID>.plist for admin
        # discoverability
        set_pref(pref_name, pref_value)
    if isinstance(pref_value, NSDate):
        # convert NSDate/CFDates to strings
        pref_value = str(pref_value)
    return pref_value

def run_today():
    # Has the preference ever been set? If not, this this the first time
    # the script has ever run, so obviously they've not see it today
    last_shown = pref('last_shown')
    if last_shown == None:
        return False

    # Convert the last shown timestamp to a date we can work with
    last_shown = datetime.datetime.fromtimestamp(int(last_shown))
    # Get today's date
    now = datetime.datetime.now()
    # Get the time delta between now and 23 hours ago
    day_ago = now - datetime.timedelta(hours=23)
    # Python can work out which one is bigger - go python!
    if last_shown > day_ago:
        print 'Last shown within last 23 hours'
        return True
    else:
        print 'Not shown with last 23 hours'
        return False

def set_run_today():
    now = int(time.time())
    set_pref('last_shown', now)

def main():
    if run_today() == False:
        # This sets the preference with the current unix timestamp
        set_run_today()
        # And call Yo with our options
        run_yo(url='munki://detail-InstallElCap',
                title='Operating System Update',
                text='Your Mac is out of date, '\
                'please upgrade ASAP.')

if __name__ == '__main__':
    main()
```

The final step is to only limit this to machines that need it - those under 10.11. We would usually use Munki to restrict who gets this, but just in case it gets manually installed somehow, let's protect ourselves.

``` python payload/opt/grahamgilbert/bin/updatenotifier
#!/usr/bin/python

import datetime
import platform
import subprocess
import time

from Foundation import *

BUNDLE_ID = 'com.grahamgilbert.updatenotifier'

def run_yo(title, text, url):
    cmd = [
        '/Applications/Utilities/yo.app/Contents/MacOS/yo',
        '--title',
        title,
        '--info',
        text,
        '--action-btn',
        'More Info',
        '--action-path',
        url
    ]
    subprocess.call(cmd)

def set_pref(pref_name, pref_value):
    CFPreferencesSetAppValue(pref_name, pref_value, BUNDLE_ID)
    CFPreferencesAppSynchronize(BUNDLE_ID)

def pref(pref_name):
    default_prefs = {
        # 'last_shown' : NSDate.new(),
    }
    pref_value = CFPreferencesCopyAppValue(pref_name, BUNDLE_ID)
    if pref_value == None:
        pref_value = default_prefs.get(pref_name)
        # we're using a default value. We'll write it out to
        # /Library/Preferences/<BUNDLE_ID>.plist for admin
        # discoverability
        set_pref(pref_name, pref_value)
    if isinstance(pref_value, NSDate):
        # convert NSDate/CFDates to strings
        pref_value = str(pref_value)
    return pref_value

def run_today():
    # Has the preference ever been set? If not, this this the first time
    # the script has ever run, so obviously they've not see it today
    last_shown = pref('last_shown')
    if last_shown == None:
        return False

    # Convert the last shown timestamp to a date we can work with
    last_shown = datetime.datetime.fromtimestamp(int(last_shown))
    # Get today's date
    now = datetime.datetime.now()
    # Get the time delta between now and 23 hours ago
    day_ago = now - datetime.timedelta(hours=23)
    # Python can work out which one is bigger - go python!
    if last_shown > day_ago:
        print 'Last shown within last 23 hours'
        return True
    else:
        print 'Not shown with last 23 hours'
        return False

def set_run_today():
    now = int(time.time())
    set_pref('last_shown', now)

def main():

    # platform.mac_ver() gives us ('10.11', ('', '', ''), 'x86_64')
    # so the first part is useful here
    mac_version = platform.mac_ver()[0]

    if run_today() == False and (mac_version.startswith('10.10') \
                        or mac_version.startswith('10.9')):
        # This sets the preference with the current unix timestamp
        set_run_today()
        # And call Yo with our options
        run_yo(url='munki://detail-InstallElCap',
                title='Operating System Update',
                text='Your Mac is out of date, '\
                'please upgrade ASAP.')

if __name__ == '__main__':
    main()
```

All that's left now is to rebuild the package.

``` bash
$ pkgbuild --root payload --identifier com.grahamgilbert.updatenotifier --version 1.1.0 ~/Desktop/UpdateNotifier.pkg
```
