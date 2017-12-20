---
title: Custom DEP Packages
date: 2017-12-20T09:42:55-08:00
layout: post
categories:
 - DEP
 - High Sierra
 - MDM
---

I'm sure everyone who didn't have an MDM a few weeks ago is scrambling to get one set up - I'm not going to go into anything about MDM, since it really isn't that interesting. They install profiles and packages - all very unexciting.

This article will take you through some of the decisions we made when developing our DEP enrollment package.

# First attempt

If you are of the open source management tool persuasion, chances are that like me, you are very happy with what you have already and see MDM merely as a method for delivering those tools. Before we considered MDM, our deployment workflow was essentially:

* Imagr lays down a base image
* Imagr installs [Google's Plan B](https://github.com/google/macops-planb)
* Plan B install Puppet
* Puppet performs the configuration
* As part of that configuration, Puppet installs [Munki](https://github.com/munki/munki)
* Munki installs the software

So on the face of it, it looked pretty simple for us to use our existing Plab B package with InstallApplication via an MDM.

# DEPNotify

[DEPNotify](https://gitlab.com/Mactroll/DEPNotify) is a great tool by Joel Rennich - you can pass in various commands and it will let your users know what is going on. So we would open up DEPNotify and then kick off our Plan B installation. Which could sit there for 10 minutes without letting the user know what was going on other than "something is happening". Whilst this obviously wasn't a great experience for our users, it got the job done.

# First optimization

Rather than make our users sit there and twiddle their thumbs whilst their computer sorted it's life out, stopped and though about what our users needed to do first off. From our perspective, we really wanted the computer encrypyed before they did anything, and we needed them to get going with our SSO solution and change their password, set up 2FA etc. So this boiled down to two basic requirements:

* Install Chrome - this is where the majority of 'IT Time' is spent during onboarding, so there was no need to wait for Munki to finally put it there.
* Install and configure [Crypt](https://github.com/grahamgilbert/crypt) - let's get the disruptive logout out of the way and let the user use their computer undisturbed.<!-- more -->

# File Watcher

The next stage was to start letting the user know what was happening. I started going down the route of modifying our Puppet modules to support outputting text into DEPNotify's log file, but this quickly became a pain - plus not all of our modules are written in house, so we would need to hope that the maintainer decided to merge our PR. So the next best thing was to watch the changes on disk and when certain files or directories appear on disk, we let the user know wha is happening. If I were a smarter person I would probably have used some PyObj-C framework to monitor for changes to the disk, but since we were only really concerned about a few pieces, a simple for loop sufficied. Below is an example of what we ran via a LaunchAgent. In addition to updating DEPNotify when some important files were put on disk, it also puts our default browser in the Dock, removes some apps we don't want in there and will pop Munki in when it makes it on disk.

``` python
#!/usr/bin/python

"""
Watches for files and posts notifications
"""

import os
import time
import subprocess
import sys
# utils is a libaray of common functions we wrote, such as writing to DEPNotify's log
import utils

def find_dock_item(item):
    cmd = [
    '/opt/company/dep_enroll/dockutil',
    '--find',
    item
    ]

    try:
        subprocess.check_output(cmd)
        return True
    except subprocess.CalledProcessError:
        return False

def unload_launchagent():
    cmd = [
        '/bin/launchctl',
        'unload',
        '/Library/LaunchAgents/com.company.dep_file_watcher.plist'
    ]
    subprocess.call(cmd)


def main():
    """
    It's the main event
    """
    # We don't list everything here, only things that either take a while (big software packages) or may require them to take action (to connect to the corp network).
    paths_and_messages = {
        '/Library/LaunchDaemons/com.company.pf.plist': 'Configuring Firewall',
        '/usr/local/osquery': 'Installing osquery',
        '/Library/Application Support/libykneomgr': 'Installing Yubikey tools',
        '/usr/local/munki/managedsoftwareupdate': 'Installing Managed Software Center',
        '/opt/puppetlabs/puppet/cache/certificates': 'Installing certificates',
        '/opt/puppetlabs/puppet/cache/mobileconfigs/com.company.dot1x': 'Configuring Company Network'
    }

    # We touch this file when Puppet is finished, so we don't do this on provisioned machines
    if os.path.exists('/private/var/db/.DEPSetupDone'):
        time.sleep(30)
        unload_launchagent()
        sys.exit(0)

    while True:
        items_to_remove = []
        # Wait for DEPNotify to open
        if utils.is_app_running('DEPNotify') is False:
            time.sleep(1)
            continue
        # We touch this when the bootstrap is done
        if os.path.exists('/tmp/.dep_enroll_done'):
            unload_launchagent()
            sys.exit(0)

        if find_dock_item('Mail') == True:
            subprocess.call([
                    dockutil,
                    '--remove',
                    'Mail'
                    ])
            time.sleep(1)
            subprocess.call(['/usr/bin/killall', 'Dock'])
        if find_dock_item('Contacts') == True:
            subprocess.call([
                    dockutil,
                    '--remove',
                    'Contacts'
                    ])
            time.sleep(1)
            subprocess.call(['/usr/bin/killall', 'Dock'])
        if find_dock_item('Calendar') == True:
            subprocess.call([
                    dockutil,
                    '--remove',
                    'Calendar'
                    ])
            time.sleep(1)

        if find_dock_item('Safari') == True and find_dock_item('Google Chrome') == False:
            if os.path.exists('/Applications/Google Chrome.app'):
                subprocess.call([
                    dockutil,
                    '--add',
                    '/Applications/Google Chrome.app',
                    '--replacing',
                    'Safari'
                    ])
                time.sleep(1)
                subprocess.call(['/usr/bin/killall', 'Dock'])

        if find_dock_item('Managed Software Center') == False:
            if os.path.exists('/Applications/Managed Software Center.app'):
                subprocess.call([
                    dockutil,
                    '--add',
                    '/Applications/Managed Software Center.app',
                    '--position',
                    'end'
                    ])
                time.sleep(1)
                subprocess.call(['/usr/bin/killall', 'Dock'])
        for path, message in paths_and_messages.iteritems():
            if os.path.exists(path):
                items_to_remove.append(path)
                utils.deplog('Status: %s' % message, chmod=False)
        for item in items_to_remove:
            del paths_and_messages[item]
        if not paths_and_messages:
            break
        time.sleep(1)

if __name__ == '__main__':
    main()

```

# Overweight packages

With Chrome and the rest of the things we wanted to install before anything else happened, our package was nudging 100MB - this left the user sitting at setup assistant with no idea that anything was happening apart from a spinning cog or even worse, at a vanilla macOS desktop with no idea what to do now.

We looked at [InstallApplications by Erik Gomez](https://github.com/erikng/installapplications), and whilst it would get us most of the way to where we wanted to be, we wanted a few other features from it (such as after we knew Crypt would be installed, we wanted to test if encryption was enabled and prompt the user to log out immediately if we needed to encrypt the disk). I did however happily steal many of it's ideas and a lot of it's code!

This allowed us to get our bootstrap package down to just a few scripts and a LaunchAgent and LaunchDaemon - down from 100MB-ish to just a few KB. This meant that even if the person going through Setup Assistant was very fast, they would only need to wait for DEPNotify to download before getting guided through the setup process.

# Threads

Running Plan B and then running Munki afterwards was fine when we were imaging. The tech doing the imaging would kick the machine off and then go do something else whilst they waited for the machine to finish building. We couldn't do this with a DEP style deployment - we needed to get everything completed as quickly as possible. Threads to the rescue!

By using threads, we are able to run two or more pieces of code in parallel. This meant that as soon as Munki is installed on the device by Puppet, we can kick off a run whilst Puppet continues to configure the rest of the machine.

The below snippet will wait for both Munki and it's configuration profile to be in place, and when it is, will run `managedsoftwareupdate --auto`.

``` python
#!/usr/bin/python

import os
import subprocess
import utils
import threading

def run_munki():
    """
    Runs managedsoftwareupdate --auto
    """
    while True:
        if os.path.exists('/usr/local/munki/managedsoftwareupdate') and \
        os.path.exists('/opt/puppetlabs/puppet/cache/mobileconfigs/ManagedInstalls'):
            break
        else:
            time.sleep(1)
    utils.deplog('Command: DeterminateManualStep: ')
    utils.deplog('Status: Checking for software updates...')


    cmd = ['/usr/local/munki/managedsoftwareupdate', '--auto']

    try:
        subprocess.check_output(cmd)
    except subprocess.CalledProcessError:
        utils.deplog('Command: Alert: Please contact AirSupport. Failed to run managedsoftwareupdate.')

def main():
    """
    MAAAIINNN
    """
    # Lots of other things happen here...
    # Now we can wait for munki to be installed
    munki_thread = threading.Thread(target=run_munki)
    munki_thread.start()
    
    # Here we can do other things whilst we wait for Munki to install and do it's thing
    ...
    # And now we need to wait for Munki to finish before we clean up
    munki_thread.join()

    subprocess.call(['/usr/sbin/softwareupdate', '--schedule', 'on'])
    open('/tmp/.dep_enroll_done', 'a').close()
    utils.deplog('Status: Configuration complete')
    utils.deplog('Quit: You\'re all set! Enjoy your new computer.')
    cleanup()

if __name__ == '__main__':
    main()
```

If we wanted to, we could also add in a few default pieces of optional software:

``` python
path = '/Library/Managed Installs/manifests'

if not os.path.exists(path):
    os.makedirs(path)

manifest = dict(
    managed_installs=[
        'GoogleChrome',
        '1Password'
        ],
    managed_uninstalls=[],
)

if not os.path.exists('/Library/Managed Installs/manifests/SelfServeManifest'):
    plistlib.writePlist(manifest,'/Library/Managed Installs/manifests/SelfServeManifest')
  ```

# Final touches

Our particular mdm doesn’t offer authentication during DEP enrollment at the moment - this doesn’t particularly bother me as there is no support for SAML or 2fa in Apple's (awful) present implementation. We are in the process of writing something to solve this, but for now it is sufficient to ensure the device is in our inventory and is assigned to a user before enrollment continues. To solve this, we wrote a small webapp that queries inventory and returns a Boolean to the launchdaemon. If the device is unassigned the process halts and uses DEPNotify to let the user know what has happened and to contact our support folks. This is only useful to us because we are treating MDM merely as a delivery mechanism - the user is unable to proceed to get a Puppet certificate signed, so will be unable to get a correctly configured machine.

One last problem we had was enrolling existing machines into MDM - they would get this package regardless of whether their machine was fully configured or not. Our solution to this was decidedly low tech - we dropped a file in `/var/db` with Puppet as the very last thing it does. We simply then exited and cleaned up immediately if the file is present - this prevented our existing machines having to sit through the (admittedly very pretty!) bootstrap process.
