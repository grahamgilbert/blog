---
layout: post
title: "Managing the Authorization Database with Munki"
date: 2013-12-22 15:25
comments: true
categories: 
- OS X
- Munki
- Python
---
Have you ever wished you didn't have to take calls from your users to unlock various parts of System Preferences? That standard users could unlock Energy Saver or Date and Time preferences? Well dear reader, this is the article for you.

If, for some strange reason you can't be bothered to read this overly long article (I do love to procrastinate), you can head over to my [macscripts repo on GitHub](https://github.com/grahamgilbert/macscripts/tree/master/Munki) for the scripts and resulting pkginfo files I've made for this.

Before we start, let's get one thing out of the way - Munki isn't at heart a configuration management system. I've traditionally preferred Puppet for these tasks, but as there is at the time of writing a [bug open](https://projects.puppetlabs.com/issues/22830) on modifying this with Puppet, I took it upon myself to make this work in my environment. I spent a couple of days trying to get my sub-par Ruby skills to match my aspirations, so I moved onto a much more comfortable technology for me: Python and Munki.

To tackle this issue, I'm going to be using the same Philosophy as Puppet:

* Check if the resource exists and what it's current value is
* If required, change the value
* And be able to revert back to how things were

These translate quite nicely into ``installcheck_script``, ``postinstall_script`` and ``uninstall_script`` rolled into a ``nopkg`` pkginfo (for a good intro into how nopkg pkginfos work, see how to manage printers with them over on the [Munki wiki](https://code.google.com/p/munki/wiki/ManagingPrintersWithMunki)). We could do this with a payload free package and an installcheck_script just as easily, but as we're already putting code into our pkginfo, we might as well keep it all in one place.

This isn't intended to be a tutorial on the theory of OS X's authorization database - there are already [excellent resources available](http://mattsmacblog.wordpress.com/2012/01/05/making-use-of-the-etcauthorization-file-in-lion-10-7-x/).

## installcheck_script

Our ``installcheck_script`` is going to be very basic. To first open up the root ``system.preferences`` right, we just need to make sure that the group is set to ``everyone`` rather than ``admin``. If you want to use another group, just substitute it in the ``group`` variable in the installcheck_script and the postinstall_script.

{% codeblock lang:python installcheck.py %}
#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Group System Preferences should be opened to
group = 'everyone'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()

formatted = plistlib.readPlistFromString(out)
# if group matches, exit 1 as we don't need to install
if formatted['group'] == group:
    sys.exit(1)
else:
    # if it doesn't we're exiting with 0 as we need to perform the install
    sys.exit(0)
{% endcodeblock %}

## postinstall_script

The ``postinstall_script`` is just an extension of the ``installcheck_script`` - but we're going to make use of Python's built-in ``plistlib`` to modify the plist and feed it back into ``security authorizationdb`` to set our desired settings.

{% codeblock lang:python postinstall.py %}
#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Group System Preferences should be opened to
group = 'everyone'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()
formatted = plistlib.readPlistFromString(out)

# If the group doesn't match, we're going to correct it.
if formatted['group'] != group:
    #input_plist = {}
    formatted['group'] = group
    # Convert back to plist
    input_plist = plistlib.writePlistToString(formatted)
    # Write the plist back to the authorizationdb
    command = ['security', 'authorizationdb', 'write', 'system.preferences']
    task = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = task.communicate(input=input_plist)
{% endcodeblock %}

## uninstall_script

We should be good admins and clean up after ourselves, so we'll include an uninstall script.

{% codeblock lang:python uninstall.py %}
#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Set the group back to admin
group = 'admin'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()
formatted = plistlib.readPlistFromString(out)

# If the group doesn't match, we're going to correct it.
if formatted['group'] != group:
    formatted['group'] = group
    # Convert back to plist
    input_plist = plistlib.writePlistToString(formatted)
    # Write the plist back to the authorizationdb
    command = ['security', 'authorizationdb', 'write', 'system.preferences']
    task = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = task.communicate(input=input_plist)
{% endcodeblock %}

## Getting it into Munki

Now we've got our three scripts, we need to get them together into a pkginfo file. Assuming the scripts you've just made live in ``~/src/macscripts/Munki/Auth``:

{% codeblock %}
$ cd ~/src/macscripts/Munki/Auth
$ /usr/local/munki/makepkginfo --installcheck_script=installcheck.py --postinstall_script=postinstall.py --uninstall_script=uninstall.py > OpenSysPrefs-1.0.plist
{% endcodeblock %}

Which will produce the bare bones of a pkginfo file, but there are a few other things we need to add into it. Modify OpenSysPref-1.0.plist to look like the below. For further documentation on what we're doing here, have a look at the [Munki wiki](https://code.google.com/p/munki/wiki/PkginfoFiles). The important parts you'll need to add / modify are:

* autoremove
* catalog
* description
* display_name
* name
* installer_type
* minimum_os_version
* version
* unattended_install (if you want it to apply in the background)
* uninstall_method
* uninstallable

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>autoremove</key>
    <false/>
    <key>catalogs</key>
    <array>
        <string>production</string>
    </array>
    <key>description</key>
    <string>Opens System Preferences to Everyone</string>
    <key>display_name</key>
    <string>Open System Preferences</string>
    <key>name</key>
    <string>OpenSysPrefs</string>
    <key>installer_type</key>
    <string>nopkg</string>
    <key>minimum_os_version</key>
    <string>10.8.0</string>
    <key>unattended_install</key>
    <true/>
    <key>version</key>
    <string>1.0</string>
	<key>installcheck_script</key>
	<string>#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Group System Preferences should be opened to
group = 'everyone'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()

formatted = plistlib.readPlistFromString(out)

# if group matches, exit 1 as we don't need to install
if formatted['group'] == group:
    sys.exit(1)
else:
    # if it doesn't we're exiting with 0 as we need to perform the install
    sys.exit(0)</string>
	<key>postinstall_script</key>
	<string>#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Group System Preferences should be opened to
group = 'everyone'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()
formatted = plistlib.readPlistFromString(out)

# If the group doesn't match, we're going to correct it.
if formatted['group'] != group:
    #input_plist = {}
    formatted['group'] = group
    # Convert back to plist
    input_plist = plistlib.writePlistToString(formatted)
    # Write the plist back to the authorizationdb
    command = ['security', 'authorizationdb', 'write', 'system.preferences']
    task = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = task.communicate(input=input_plist)</string>

	<key>uninstall_method</key>
	<string>uninstall_script</string>
	<key>uninstallable</key>
	<true/>
	<key>uninstall_script</key>
	<string>#!/usr/bin/env python

import subprocess
import sys
import plistlib

# Set the group back to admin
group = 'admin'

command = ['security', 'authorizationdb', 'read', 'system.preferences']

task = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(out, err) = task.communicate()
formatted = plistlib.readPlistFromString(out)

# If the group doesn't match, we're going to correct it.
if formatted['group'] != group:
    formatted['group'] = group
    # Convert back to plist
    input_plist = plistlib.writePlistToString(formatted)
    # Write the plist back to the authorizationdb
    command = ['security', 'authorizationdb', 'write', 'system.preferences']
    task = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = task.communicate(input=input_plist)</string>
</dict>
</plist>
{% endcodeblock %}

At this point, you should be able to add this pkginfo to your Munki repository, include it in a manifest and - well, nothing will happen, as this only unlocks the top level of System Preferences. If you want to do more, you'll need to unlock additional parts as well - the scripts to do this can be found in my [macscripts repository](https://github.com/grahamgilbert/macscripts/tree/master/Munki). I've specified that ``OpenSysPrefs`` is required in all of these - this means I can include only the needed modifications in the manifest and not worry about the top level being unlocked.

Also remember that Munki has conditional items built right in - you might only want to unlock the Network pane on laptops so they can install VPN profiles etc using something like this:

{% codeblock lang:xml %}
<key>conditional_items</key>
<array>
  <dict>
    <key>condition</key>
    <string>machine_type == "laptop"</string>
    <key>managed_installs</key>
    <array>
      <string>UnlockNetwork</string>
    </array>
  </dict>
</array>
{% endcodeblock %}