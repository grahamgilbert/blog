---
title: Uninstalling TeamViewer 10 with Munki
---

I think TeamViewer is a great product - it has rarely failed me when I needed to get onto a remote OS X machine. Apart from the fact that they treat their Mac deployment options like an unwanted child. You can only set an unattended access password on OS X if you do it by hand, and their uninstall options - well, go have a look at their support document on it. Fine for one machine. Not so great for thousands. It just screams enterprise at you, doesn't it? <!-- more -->

So, in the end we decided to stick with the QuickSupport app, as we didn't need to worry about our users setting the password themselves. And for it to work reliably, we needed to uninstall TeamViewer Host. I had a quick look at what it installed, and ran the following script on my test VM.

``` bash
#!/bin/bash

# Failed attempt number one

/bin/launchctl unload /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist 
/bin/launchctl unload /Library/LaunchDaemons/com.teamviewer.Helper.plist

/bin/rm -rf /Applications/TeamViewerHost.app
/bin/rm /Library/Fonts/TeamViewer10Host.otf
/bin/rm /Library/LaunchAgents/com.teamviewer.teamviewer.plist
/bin/rm /Library/Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist
/bin/rm /Library/LaunchDaemons/com.teamviewer.Helper.plist
/bin/rm /Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist 
/bin/rm -f /Library/Preferences/com.teamviewer.teamviewer10.plist
/bin/rm /Library/PrivilegedHelperTools/com.teamviewer.Helper
/bin/rm -rf /Library/Security/SecurityAgentPlugins/TeamViewerAuthPlugin.bundle

/usr/sbin/pkgutil --forget com.teamviewer.teamviewerhost10
/usr/sbin/pkgutil --forget com.teamviewer.teamviewerhost10Font
/usr/sbin/pkgutil --forget com.teamviewer.teamviewerhost10Agent
/usr/sbin/pkgutil --forget com.teamviewer.teamviewerhost10Restarter
/usr/sbin/pkgutil --forget com.teamviewer.teamviewer10AuthPlugin
```

And then I rebooted. The Mac wouldn't boot. Fan-bloody-tastic.

I repeat: if you just remove the files the package installs, you will be left with an inoperable Mac.

Then after my work on moving Crypt to an authorization plugin, I realised they must be calling the mechanism in the authorization database. So the next script will also modify the authorization database so the Mac won't expect that plugin to be present. This script is also on my GitHub, which will be kept up to date if things change.

``` python
#!/usr/bin/python

"""
Removes TeamViewer Host 10 from an OS X Machine.
"""

import os
import plistlib
import platform
import subprocess
import shutil
from subprocess import Popen, PIPE, STDOUT
import sys

system_login_console_plist = "/private/var/tmp/system.login.console.plist"
mechs = ["TeamViewerAuthPlugin:start"]

def rm(path):
    if os.path.exists(path):
        try:
            os.remove(path)
        except:
            shutil.rmtree(path)


def bash_command(script):
    try:
        return subprocess.check_output(script)
    except (subprocess.CalledProcessError, OSError), err:
        sys.exit("[* Error] **%s** [%s]" % (err, str(script)))

def remove_mechs_in_db(db, mech_list):
    for mech in mech_list:
        for old_mech in filter(lambda x: mech in x, db['mechanisms']):
            db['mechanisms'].remove(old_mech)
    return db

def edit_authdb():
    ## Export "system.login.console"
    system_login_console = bash_command(["/usr/bin/security", "authorizationdb", "read", "system.login.console"])
    f_c = open(system_login_console_plist, 'w')
    f_c.write(system_login_console)
    f_c.close()

    ## Leave the for loop. Possible support for ScreenSaver unlock
    for p in [system_login_console_plist]:
        ## Parse the plist
        d = plistlib.readPlist(p)

        ## Add FV2 mechs
        d = remove_mechs_in_db(d, mechs)

        ## Write out the changes
        plistlib.writePlist(d, p)

    f_c = open(system_login_console_plist, "r")
    p = Popen(["/usr/bin/security", "authorizationdb", "write", "system.login.console"], stdout=PIPE, stdin=PIPE, stderr=PIPE)
    stdout_data = p.communicate(input=f_c.read())
    f_c.close()

def main(argv):
    edit_authdb()
    # we're being nice unloading the launchdaemons, but we don't really care
    try:
        bash_command(['/bin/launchctl', 'unload', '/Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist'])
    except:
        pass

    try:
        bash_command(['/bin/launchctl', 'unload', '/Library/LaunchDaemons/com.teamviewer.Helper.plist'])
    except:
        pass

    rm('/Applications/TeamViewerHost.app')
    rm('/Library/Fonts/TeamViewer10Host.otf')
    rm('/Library/LaunchAgents/com.teamviewer.teamviewer.plist')
    rm('/Library/LaunchAgents/com.teamviewer.teamviewer_desktop.plist')
    rm('/Library/LaunchDaemons/com.teamviewer.Helper.plist')
    rm('/Library/LaunchDaemons/com.teamviewer.teamviewer_service.plist')
    rm('/Library/Preferences/com.teamviewer.teamviewer10.plist')
    rm('/Library/PrivilegedHelperTools/com.teamviewer.Helper')
    rm('/Library/Security/SecurityAgentPlugins/TeamViewerAuthPlugin.bundle')

    bash_command(['/usr/sbin/pkgutil', '--forget', 'com.teamviewer.teamviewerhost10'])
    bash_command(['/usr/sbin/pkgutil', '--forget', 'com.teamviewer.teamviewerhost10Font'])
    bash_command(['/usr/sbin/pkgutil', '--forget', 'com.teamviewer.teamviewerhost10Agent'])
    bash_command(['/usr/sbin/pkgutil', '--forget', 'com.teamviewer.teamviewerhost10Restarter'])
    bash_command(['/usr/sbin/pkgutil', '--forget', 'com.teamviewer.teamviewer10AuthPlugin'])


if __name__ == '__main__':
    main(sys.argv)
```

And if anyone from TeamViewer is reading, this literally took me an hour to write. It's disgraceful that you don't offer an uninstall method that doesn't require me to go to each and every machine and do it by hand.