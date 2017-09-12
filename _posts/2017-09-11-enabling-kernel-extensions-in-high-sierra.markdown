---
title: Enabling Kernel Extensions in High Sierra
date: 2017-09-11T15:17:47-07:00
layout: post
categories:
 - Imagr
 - High Sierra
---

In macOS 10.13 High Sierra, Apple is introducing [Secure Kernel Extension Loading](https://developer.apple.com/library/content/technotes/tn2459/_index.html) (or SKEL for short). This takes the changes introduced with SIP (requiring all KEXTs to be signed) one step further to requiring the user to enable them manually. Whilst this is great for home users, this absolutely sucks for those of us who manage macOS in the enterprise (who need things like VPN clients and anti malware tools running).

## What can we do?

Obviously the long term future for managing macOS is MDM only, and Apple has taken the first step of adding an MDM only management feature for macOS - if the Mac is enrolled in an MDM, SKEL will be disabled, with the promise of more fine grained control in the future. But what if you don’t have an MDM yet?

Apple has added functionality to `spctl` to allow you to manage this. At it’s most basic you can turn the functionality on or off - this probably isn’t what you really want to do. What most people will want to do is to whitelist the extensions they actually use.

## Get the IDs

The first thing you will want to do is to get a clean install of High Sierra (not an upgrade) and install the KEXTs you need. Click ok on the prompt telling you the world will fall over if you enable it and then ignore that and head over to System Preferences -> Security and click on the Allow button.

Once all of your KEXTs are loaded, fire up Terminal and open up the database that actually stores all of this information.

```
$ sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy
```

Your button clicking will result in a Team ID being whitelisted in the `kext_policy` table. Let’s  have a look in there:

```
SELECT * FROM kext_policy;
```

You will see the Team ID, the bundle ID for each individual extension and the display name of the developer. Note down the Team ID (the first item) - you will need all the IDs for the extensions you wish to whitelist.

## csrutil

Apple has allowed us to interact with this database only when booted from Recovery HD - or a Recovery-like operating system - of which a NetInstall is one. If you are using either the default NBI from Imagr or one created with NBICreator, you will be running a NetInstall. This means you can script the addition of these Team IDs during your provisioning workflow.

Create a script like the following, adding a line for each of the Team IDs you want to whitelist.

``` bash
#!/bin/bash

# Palo Alto
/usr/sbin/spctl kext-consent add PXPZ95SK77
```

And if you are using Imagr, you will want to add a component like the following - note that it has had the `first_boot` option set to `false` - we need this to run _during_ the NetInstall session.

``` xml
<dict>
    <key>first_boot</key>
    <false/>
    <key>type</key>
    <string>script</string>
    <key>url</key>
    <string>https://yourimagrserver.company.com/scripts/enable_kexts.sh</string>
</dict>
```

## What can be better here?

Obviously this is a short term fix. We all need to get an MDM up and running to manage this in the future, I fully expect this functionality to disappear in the future release. And we can obviously only manage this during deployment time. This workflow wouldn’t work if we had DEP workflow, or if we needed to deploy a new kernel extension to the existing fleet (retrieving and NetBooting several thousand laptops isn’t practical for anybody). BUT Apple hasn’t yet provided any mechanism to manage these via MDM other than completely turning the feature off, so we this is as good as we can do right now.

And one last thing - this whitelist is stored in NVRAM. If resetting the PRAM / NVRAM is part of your standard troubleshooting runbook, you should delete that part now.
