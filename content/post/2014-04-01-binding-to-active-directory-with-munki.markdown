---
categories:
- OS X
- Munki
- Bash
- Active Directory
comments: true
date: "2014-04-01T20:15:39Z"
title: Binding to Active Directory with Munki
---
Many organisations need to bind their Macs to AD. There are quite a few options however, that need to be changed. It's quite  a straightforward process to automate this with Munki, although you do have a few options to consider.

First off, how are you going to deliver the actual bind script? You have the option of a [no-pkg pkginfo](https://code.google.com/p/munki/wiki/ManagingPrintersWithMunki#Alternate_Method_Using_nopkg) file, with the script directly in the pkginfo plist. Whilst the script is now easily editable in the pkginfo, it does pose a security issue in that the catalog is kept in /Library/Managed Installs/catalogs, which will contain your script. Along with your AD bind account's details. Whoops!

## Prepare the Bind!

My preferred way of deploying the bind script is with a payload-free package made with The Luggage. My bind script is nothing special, it was originally borrowed from DeployStudio. You can find the [script](https://github.com/grahamgilbert/macscripts/blob/master/AD%20Bind/postinstall) and the [Makefile](https://github.com/grahamgilbert/macscripts/blob/master/AD%20Bind/Makefile) on my [macscripts repo](https://github.com/grahamgilbert/macscripts/tree/master/AD%20Bind). If you need a primer on The Luggage, [I wrote about it in August 2013](http://grahamgilbert.com/blog/2013/08/09/the-luggage-an-introduction/). You just need to edit the variables at the top of the script to suit your environment and build the package.

So you've got the machine bound to AD. Great. What happens if the binding doesn't go to plan? Or a well meaning tech manages to unbind the machine, but can't manage to re-bind it? Or even worse, the user manages to unbind it themselves? We need to make Munki check that the Mac is still bound to AD.

<!--more-->

## installcheck_script.sh

``` bash
#!/bin/sh

# You need to change this.

# The Domain we're supposed to be on
DOMAIN="ad.company.com"

## STOP EDITING ##

# The version from dsconfigad
ACTUAL_DOMAIN=`/usr/sbin/dsconfigad -show | /usr/bin/grep -i "Active Directory Domain" | /usr/bin/sed -n 's/[^.]*= //p'`

if [ "$ACTUAL_DOMAIN" = "$DOMAIN" ]
    then
    # We're on the right domain, no need to install
    exit 1
else
    # Domain isn't being returned from dsconfigad, need to install
    exit 0
fi
```


You should save this as install ``check_script.sh`` in the same directory as your binding package. This script is querying the Active Directory domain the Mac is on and checking it's the one you want. 

Simple. 

Job done.

Right...?

## Not quite finished

The main issue with using an ``installcheck_script`` is that we're bypassing every other mechanism that Munki uses to check if an item needs to be installed, which means that if we ever need to update our AD bind package and install it, or if the Mac was previously bound to AD, Munki will cheerfully ignore the package because as far as it's concerned, if it passes the installcheck_script, everything's fine and dandy.

## installcheck_script.sh take 2

``` bash
#!/bin/sh

# You need to change these.

# The Domain we're supposed to be on
DOMAIN="ad.company.com"

# The version of the package (today's date if created using the usual Luggage Makefile)
PKG_VERSION="20140401"

# The identifier of the package
PKG_ID="com.grahamgilbert.ad-bind"

## STOP EDITING ##

# The version from dsconfigad
ACTUAL_DOMAIN=`/usr/sbin/dsconfigad -show | /usr/bin/grep -i "Active Directory Domain" | /usr/bin/sed -n 's/[^.]*= //p'`

# The version installed from pkgutil
VERSION_INSTALLED=`/usr/sbin/pkgutil --pkg-info ${PKG_ID} | /usr/bin/grep version | /usr/bin/sed 's/^[^:]*: //'`
if [ "$ACTUAL_DOMAIN" = "$DOMAIN" ]
    then
    # We're on the right domain, make sure we've got the right version of the package
    if [ "$VERSION_INSTALLED" = "$PKG_VERSION" ]
    then
        # Everything's ok, no need to install
        exit 1
    else
        # Package is out of date, need to install
        exit 0
    fi
else
    # Domain isn't being returned from dsconfigad, need to install
    exit 0
fi
```

This is a little more complicated, but not much. First off we're doing the same check as before, making sure we're actually bound to the domain. If we aren't, we obviously need to install the package, so that's the end of that. If we are bound, we next need to check which version of the package we have. As previously mentioned, Munki would usually do this for us, but by using the installcheck_script, we've engaged the "leave me alone, I know what the fuck I'm doing" mode in Munki, so we're implementing that check ourselves. If the version or package identifier don't match, we want our bind script installed, screw those other guys with their not-as-good-as-our-way of binding.

All that's left now is to ``munkiimport`` your package with your script as an ``installcheck_script``:

``` bash
$ /usr/local/munki/munkiimport ad-bind.pkg --installcheck_script=installcheck_script.sh
```

There you have it, how to keep a Mac bound to AD with Munki. You may wish to change some other settings later on (particularly if you have to do battle with a .local domain), but this will get you going with a basic AD bind.
