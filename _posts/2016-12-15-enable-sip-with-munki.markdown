---
title: Enable SIP with Munki
date: 2016-12-15T14:47:43-08:00
layout: post
categories:
 - Munki
---

When 10.12.2 hit this week, it introduced an awesome new feature - the [ability to enable SIP](https://onemoreadmin.wordpress.com/2016/12/13/system-integrity-protection-sip-changes-in-macos-sierra-10-12-2/) without having to be booted into a Recovery like environment (either Recovery HD or a NetInstall). Unfortunately it merely enables SIP on the next reboot.

Fortunately, Munki is pretty good at telling users when they need to reboot, so I wrote the following pkgsinfo file that will check if SIP is enabled, and if it isn't, will enable it and reboot (fortunately it's quite a bit easier to do this that it is with [other tools](https://babodee.wordpress.com/2016/12/15/ensuring-sip-is-enabled/). I've targeted this update at 10.12.0, because, well, if they're not updating, I'd like them to. And it's called 'Critical Security Update' so they may actually install it. If you really want them to install it, you can set a `force_install_after_date` and set it to the past, which will give your users a hour to install it before their machine goes byebye. <!-- more -->Without further ado, here it is:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>RestartAction</key>
    <string>RequireRestart</string>
    <key>_metadata</key>
    <dict>
        <key>created_by</key>
        <string>graham_gilbert</string>
        <key>creation_date</key>
        <date>2016-12-15T20:11:12Z</date>
        <key>munki_version</key>
        <string>2.8.2.2855</string>
        <key>os_version</key>
        <string>10.12.2</string>
    </dict>
    <key>autoremove</key>
    <false/>
    <key>catalogs</key>
    <array>
        <string>production</string>
    </array>
    <key>category</key>
    <string>Security</string>
    <key>description</key>
    <string>Resolves critical security issues.</string>
    <key>developer</key>
    <string>Apple</string>
    <key>display_name</key>
    <string>Critical Security Update</string>
    <key>installcheck_script</key>
    <string>#!/usr/bin/python

import subprocess
import sys

def main():
    sip_status = subprocess.check_output(['/usr/bin/csrutil', 'status'])
    if 'disabled' in sip_status:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()</string>
    <key>installer_type</key>
    <string>nopkg</string>
    <key>minimum_os_version</key>
    <string>10.12.0</string>
    <key>name</key>
    <string>enable_sip</string>
    <key>postinstall_script</key>
    <string>#!/bin/bash
/usr/bin/csrutil clear
exit 0</string>
    <key>version</key>
    <string>1.0</string>
</dict>
</plist>
```

If you have machines that are below 10.12 (and considering the [security issues](http://blog.frizk.net/2016/12/filevault-password-retrieval.html), you should consider making 10.12 a managed install), you will probably want to add it to a manifest like so:

``` xml
<key>conditional_items</key>
<array>
    <dict>
        <key>condition</key>
        <string>os_vers_minor &gt;= 12</string>
        <key>managed_installs</key>
        <array>
            <string>enable_sip</string>
        </array>
    </dict>
</array>
```