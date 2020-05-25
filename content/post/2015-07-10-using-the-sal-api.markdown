---
categories:
- Sal
- Python
comments: true
date: "2015-07-10T11:12:36Z"
title: Using the Sal API
---

As previously mentioned, Sal now has an [API](https://github.com/salopensource/sal/blob/master/docs/API.md). You might be wondering what you can do with this wonderous API. This is a simple example of using it to automate building packages to enrol Macs into Sal.

The basic workflow of this script is:

* Use the API to get a list of all Machine Groups in Sal - this will return JSON (a markup language that is easily parsable with languages like Python)
* Download the Sal postflight scripts
* Download the latest Facter installer
* For each machine group, build a package that will install all of the packages and then set the correct Sal preferences.

[You can find the script in this Gist](https://gist.github.com/grahamgilbert/8ccba318d3ecadee02b1). I'm not going to go through the script line by line, but we'll cover how to configure it.

First off you will need an API key configuring. Log into Sal as a user with Global Admin privelages and choose the 'person' menu at the top right and then choose Settings. From the sidebar, choose API keys and then choose to make a new one. Give it a name so you can recognise it - I called this one "PKG Generator". You will then be given a public key and a private key. Make a note of them, we'll need them in the next section.

## Configuring the script

Edit the variables at the top to match your environment:

``` python
# No trailing slash on this one - I was lazy and didn't check for it
SAL_URL = "https://sal.yourcompany.com"
PUBLIC_KEY = "yourpublickeyhere"
PRIVATE_KEY = "yourreallyreallyreallylongprivatekeyhere"
PKG_IDENTIFIER = "com.yourcompany.sal_enrol"
SAL_PKG = "https://github.com/salopensource/sal/releases/download/v0.4.0/sal_scripts.pkg"
FACTER_PKG = "https://downloads.puppetlabs.com/mac/facter-latest.dmg"

```

There are some caveats with this script:

* It will spit the packages out in your current directory. Make sure you've ``cd``-ed into where you want the packages to be generated.
* It uses ``urllib2`` to request the information from Sal and to download the packages - this means that there is no verification of the SSL certificates, so make sure you know where you're connecting to.

All ready to run it?

``` bash
$ sudo python sal_package_generator.py
```

And you'll get a directory full of packages that will get your fleet reporting into Sal.