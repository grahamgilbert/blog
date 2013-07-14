---
layout: post
title: "Using crankd to react to network events"
date: 2013-07-12 14:04
comments: true
categories: 
- OS X
- Python
---
Updated 14/7/2013: After [Alister's suggestion](https://twitter.com/Sacrilicious/status/355756510535614464), the script now loops over network interfaces up to en19 (hopefully that's enough!).

So, you've heard of this crankd thing, maybe even had a look at it, but have no idea how to get it going? You're in the right place. I'm by no means an expert on it, having only been playing with it for less than a week, but I already have it running in production running the simple script below. My initial work, and therefore this post was inspired by Gary Larizza's [two](http://web.archive.org/web/20120111031339/http://glarizza.posterous.com/using-crankd-to-react-to-network-events) [articles](http://garylarizza.com/blog/2011/12/31/using-the-google-macops-crankd-and-facter-code/) on the subject.

## What is crankd?

It's part of the [PyMacAdmin](https://code.google.com/p/pymacadmin/) set of tools that [Chris Adams](http://chris.improbable.org/) and [Nigel Kersten](http://explanatorygap.net) released a while ago. In a nutshell, it runs in the background via a LaunchDaemon and reacts to events on the Mac by running a script or a Python function, class or method. It has loads of events it knows about (application launches, power events, network events etc), but in this case I wanted to run something when there was a network change. Some of our machines never get turned off (and for some reason the Puppet Launch Daemon has crapped out), or aren't turned on long enough for Puppet or Munki to run. I wanted a script that would run every time the machine came back onto the network, checking if there was an active connection and run Puppet and Munki.

## What do I need to do?

There are a few parts that we need to bring together to make this work:

* The crankd.py executable and the supporting files
* A Launch Daemon to start the thing
* A preferences file to tell crankd what to do
* And finally, our custom code

<!--more-->

## Get and install crankd

First off, you need to grab the current code from GitHub.

``
git clone https://github.com/acdha/pymacadmin.git
``

Then ``cd`` into the pymacadmin directory you just cloned and run ``install-crankd.sh``.

{% codeblock lang:bash %}cd ~/src/pymacadmin
sudo ./install-crankd.sh
{% endcodeblock %}

That will install the crankd.py executable and it's supporting files, now for the Launch Daemon to make it start at boot. You'll need to put the following into a file at ``/Library/LaunchDaemons/com.googlecode.pymacadmin.crankd.plist``.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>KeepAlive</key>
    	<true/>
    	<key>Label</key>
    	<string>com.googlecode.pymacadmin.crankd</string>
    	<key>ProgramArguments</key>
    	<array>
    		<string>/usr/local/sbin/crankd.py</string>
    	</array>
    	<key>RunAtLoad</key>
    	<true/>
    </dict>
    </plist>

And set the right ownership and permissions on the plist

{% codeblock lang:bash %}sudo chmod 644 /Library/LaunchDaemons/com.googlecode.pymacadmin.crankd.plist
sudo chown root:wheel /Library/LaunchDaemons/com.googlecode.pymacadmin.crankd.plist
{% endcodeblock %}

So that's the basics. Now we need to tell crankd what events it should listen to and what it should do.

As we want to call the CrankTools class and the OnNetworkLoad method every time the network changes state, we need to do the following in ``/Library/Preferences/com.googlecode.pymacadmin.crankd.plist``. To see what other events you can use with crankd, head on over to the [GitHub repo](https://github.com/acdha/pymacadmin/tree/master/examples/crankd/sample-of-events).

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

Now for the actual Python code. This is very heavily inspired by [Gary Larizza's](http://garylarizza.com) work. We're checking if either en0 or en1 has a valid network connection (as this event is for any network change - both connecting and disconnecting), and if there is a valid connection, run Puppet and then run Munki. This code could easily be modified to run anything you wanted to at the command line (for example a Casper policy). Put the following script in ``/Library/Application Support/crankd/CrankTools.py``.

{% codeblock CrankTools.py %}#!/usr/bin/env python
#!/usr/bin/env python
#
#    CrankTools.py
#        The OnNetworkLoad method is called from crankd on a network state change, all other
#            methods assist it. Modified from Gary Larizza's script (https://gist.github.com/glarizza/626169).
#
#    Last Revised - 10/07/2013

__author__ = 'Graham Gilbert (graham@grahamgilbert.com)'
__version__ = '0.6'

import syslog
import subprocess
from time import sleep

syslog.openlog("CrankD")

class CrankTools():
    """The main CrankTools class needed for our crankd config plist"""
    
    def puppetRun(self):
        """Checks for an active network connection and calls puppet if it finds one.
            If the network is NOT active, it logs an error and exits
        ---
        Arguments: None
        Returns:  Nothing
        """
        command = ['/usr/bin/puppet','agent','-t']
        if self.LinkState():
            self.callCmd(command)
        else:
            syslog.syslog(syslog.LOG_ALERT, "Internet Connection Not Found, Puppet Run Exiting...")
    
    def munkiRun(self):
        """Checks for an active network connection and calls Munki if it finds one.
            If the network is NOT active, it logs an error and exits
        ---
        Arguments: None
        Returns:  Nothing
        """
        command = ['/usr/local/munki/managedsoftwareupdate','--auto']
        if self.LinkState():
            self.callCmd(command)
        else:
            syslog.syslog(syslog.LOG_ALERT, "Internet Connection Not Found, Munki Run Exiting...")
    
    def callCmd(self, command):
        """Simple utility function that calls a command via subprocess
        ---
        Arguments: command - A list of arguments for the command
        Returns: Nothing
        """
        task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        task.communicate()
    
    def LinkState(self):
        """This utility returns the status of the passed interface.
        ---
        Arguments:
            None
        Returns:
            status - The return code of the subprocess call
        """
        
        theState = False
        
        for interface in range(0, 20):
            interface = str(interface)
            adapter = 'en' + interface
            print 'checking adapter '+adapter
            if not subprocess.call(["ipconfig", "getifaddr", adapter]):
                theState = True
                break
        
        return theState
    
    def OnNetworkLoad(self, *args, **kwargs):
        """Called from crankd directly on a Network State Change. We sleep for 10 seconds to ensure that
            an IP address has been cleared or attained, and then perform a Puppet run and a Munki run.
        ---
        Arguments:
            *args and **kwargs - Catchall arguments coming from crankd
        Returns:  Nothing
        """
        sleep(10)
        self.puppetRun()
        self.munkiRun()

def main():
    crank = CrankTools()
    crank.OnNetworkLoad()

if __name__ == '__main__':  
    main() 
{% endcodeblock %}

It's ok, we're nearly there! You just need to set the right owner on ``CrankTools.py`` , load the Launch Daemon and we can get testing.

```
sudo chown root:wheel /Library/Application Support/crankd/CrankTools.py
sudo launchctl load /Library/LaunchDaemons/com.googlecode.pymacadmin.crankd.plist`
```

You're all set. Disconnect your network connection and re-connect. Put your Mac to sleep and wake it up. Each time, there should be a 10 second delay, then a Puppet run followed by a Munki run will happen.

If you've modified ``CrankTools.py``, you can test the changes by running the script directly.

## What's next?

Obviously this is not a good way of deploying crankd - I've got a method in the works that will build a package to install this (I currently deploy this with Puppet - I'll put in a pull request on [Gary's module](https://github.com/glarizza/puppetlabs-crankd) with my changes when I get chance). I'm also going to be doing more with crankd - possibly some application use monitoring, almost certainly some scripts fired off when a machine wakes and sleeps.