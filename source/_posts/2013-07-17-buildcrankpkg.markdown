---
layout: post
title: "buildCrankPkg"
date: 2013-07-17 16:31
published: draft
comments: true
categories: 
- OS X
- Python
- Packaging
- Munki
- Puppet
- Casper
- Script
---

In my [last post](http://grahamgilbert.com/blog/2013/07/12/using-crankd-to-react-to-network-events/) I promised a tool I've been working on to automate the building of a package for crankd.

[buildCrankPkg](https://github.com/grahamgilbert/buildCrankPkg) is a small script that will:

* Pull down the latest version of crankd (or use a local or remote repository if you specify one)
* Build a package that includes crankd and your custom settings and scripts. 
 
I've included two examples, one that implements calling Munki and Puppet as detailed in the last post, and one to run a Casper policy.

If you're happy with what crankd does and using the command line, head on over to the [repository](https://github.com/grahamgilbert/buildCrankPkg) and enjoy. If you need a bit more help to get started, read on.<!--more-->

## Tutorial

First off, you're going to need to get the buildCrankPkg repository.

{% codeblock lang:bash %}cd ~/src
git clone https://github.com/grahamgilbert/buildCrankPkg.git{% endcodeblock%}

You're left with three directories that you need to fill:

* ``crankd``: You will be putting your custom code in here.
* ``Preferences``: Just a plist that will call our custom code.
*  ``LaunchDaemons``: A LaunchDaemon to run crankd - an example that should be fine is already there.

Assuming you cloned the ``buildCrankPkg`` repository to ``~/src/buildCrankPkg``, save the following as ``~/src/buildCrankPkg/crankd/CrankTools.py`` (or copy the example). The only change between this one and the ``CrankTools.py`` from last time is that we're calling the JAMF binary to run a Casper policy (I know, the horror, I do actually use Casper occasionally). Our trigger's name is NetworkTrigger - the line you'd need to customise to change this is ``28``.

{% codeblock lang:python CrankTools.py %}
#!/usr/bin/env python
#
#    CrankTools.py
#        The OnNetworkLoad method is called from crankd on a network state change, all other
#            methods assist it. Modified from Gary Larizza's script (https://gist.github.com/glarizza/626169).
#
#    Last Revised - 10/07/2013

__author__ = 'Graham Gilbert (graham@grahamgilbert.com)'
__version__ = '0.2'

import syslog
import subprocess
from time import sleep

syslog.openlog("CrankD")

class CrankTools():
    """The main CrankTools class needed for our crankd config plist"""

    def policyRun(self):
        """Checks for an active network connection and calls the jamf binary if it finds one.
            If the network is NOT active, it logs an error and exits
        ---
        Arguments: None
        Returns:  Nothing
        """
        command = ['jamf','policy','-trigger','NetworkTrigger']
        if not self.LinkState('en1'):
            self.callCmd(command)
        elif not self.LinkState('en0'):
            self.callCmd(command)
        else:
            syslog.syslog(syslog.LOG_ALERT, "Internet Connection Not Found, Puppet Run Exiting...")

    def callCmd(self, command):
        """Simple utility function that calls a command via subprocess
        ---
        Arguments: command - A list of arguments for the command
        Returns: Nothing
        """
        task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        task.communicate()

    def LinkState(self, interface):
        """This utility returns the status of the passed interface.
        ---
        Arguments:
            interface - Either en0 or en1, the BSD interface name of a Network Adapter
        Returns:
            status - The return code of the subprocess call
        """
        return subprocess.call(["ipconfig", "getifaddr", interface])

    def OnNetworkLoad(self, *args, **kwargs):
        """Called from crankd directly on a Network State Change. We sleep for 10 seconds to ensure that
            an IP address has been cleared or attained, and then perform a Puppet run and a Munki run.
        ---
        Arguments:
            *args and **kwargs - Catchall arguments coming from crankd
        Returns:  Nothing
        """
        sleep(10)
        self.policyRun()

def main():
    crank = CrankTools()
    crank.OnNetworkLoad()

if __name__ == '__main__':
    main()
{% endcodeblock %}

Now for the preferences - no change from last time here, as we've not changed the name of our class or method. This goes into ``~/src/buildCrankPkg/Preferences/com.googlecode.pymacadmin.crankd.plist``

{% codeblock lang:xml com.googlecode.pymacadmin.crankd.plist %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>SystemConfiguration</key>
        <dict>
            <key>State:/Network/Global/IPv4</key>
            <dict>
                <key>method</key>
                    <array>
                        <string>CrankTools</string>
                        <string>OnNetworkLoad</string>
                    </array>
            </dict>
        </dict>
    </dict>
</plist>
{% endcodeblock %}

One last step until we can build our package is the Launch Daemon - we're going to use the one that's included in the repository, as 99% of people won't need to change it.

## Prepare the build!

Our package needs to have the version number of 2.1 and we're going to set the package's identifier to com.example.crankd

{% codeblock lang:bash %}cd ~/src/buildCrankPkg
sudo ./buildCrankPkg.py  --version 2.1 --identifier com.example.crankd
{% endcodeblock %}

Your package will be in ``~/src/buildCrankPkg`` waiting for you.

