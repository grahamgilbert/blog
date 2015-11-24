---
layout: post
title: "Upgrading OS X using a package"
date: 2015-09-28 11:35:55 +0100
comments: true
categories: 
- OS X
- Munki
- Python
---

It's the time of year where we start to think about upgrading our machines to the latest version of OS X. There are several ways of doing this, but assuming your users are unable to perform the upgrade themselves via the App Store (if they're running as a standard user or your policies prohibit the use of the App Store), you might be wondering how you can use your management tool to get your machines upgraded and make sure they stay enrolled in your management tool.

We're fortunate that we have a standard packaging format on OS X that virtually all management tools can install, so this is the most universal way of distributing software. Greg Neagle wrote [createOSXinstallPkg](https://github.com/munki/createOSXinstallPkg) a few years ago that has several nice features for mac admins:

* It wraps up an OS X Installer into a standard package.
* It allows you to add in additional packages - perhaps you want to make sure your admin user is installed or make sure that a version of Munki that is compatible with the new OS is installed.<!-- more -->

[Yosemite introduced](https://github.com/munki/createOSXinstallPkg#further-note-on-additional-packages-and-yosemite) a nice undocumented requirement that all packages included in the OS X installer environment are distribution packages. This is in addition to the limited OS X Installer environment not having many of the command line tools you might expect to be there.

One solution to these issues is to use [first-boot-pkg](https://github.com/grahamgilbert/first-boot-pkg) - a tool that will install a set of packages at first boot, and will wrap them in a distribution style package so it can be used with createOSXinstallPkg.

## The first boot package

Our first job is to build the package that will be installed at first boot. I am only going to make sure that Munki is installed at first boot, but some other things you might want to put in include:

* Your local admin user
* Puppet and Facter
* A payload free package to configure your SUS CatalogURL

### Prep for the first boot package

First off we're going to need the script to build a first boot package. Assuming you're going to keep your code in ``~/src``:

``` bash
$ cd ~/src
$ git clone https://github.com/grahamgilbert/first-boot-pkg.git
$ cd first-boot-pkg
```

You have two options for configuring the first boot package - you can pass it options on the command line or you can use a plist. We're using a plist as it's the most repeatable and sharable method. If you need further options, such as disabling the network check, see the [project on Github](https://github.com/grahamgilbert/first-boot-pkg).

``` xml ~/src/first-boot-pkg/first-boot-config.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Packages</key>
    <array>
        <string>munkitools-2.3.1.2535.pkg</string>
    </array>
    <key>Name</key>
    <string>post-elcap-upgrade.pkg</string>
    <key>Identifier</key>
    <string>com.company.post-elcap-upgrade</string>
    <key>Version</key>
    <string>0.1</string>
</dict>
</plist>
```

The above is assuming you've saved your Munki package to ``~/src/first-boot-pkg/munkitools-2.3.1.2535.pkg`` (i.e. in the same directory as your ``first-boot-config.plist``).

### Building the first boot package

Let's make sure we're in the right directory:

``` bash
$ cd ~/src/first-boot-pkg
```

And let's build the package:

``` bash
$ sudo ./first-boot-pkg --plist first-boot-config.plist
Validating packages:
----------------------------------------------------------------
munkitools-2.3.1.2535.pkg looks good.
----------------------------------------------------------------
pkgbuild: Inferring bundle components from contents of /tmp/tmpfCF2Ry
pkgbuild: Adding component at Library/PrivilegedHelperTools/LoginLog.app
pkgbuild: Wrote package to /tmp/tmp0kZed8/post-elcap-upgrade.pkg
productbuild: Wrote product to /Users/grahamgilbert/src/first-boot-pkg/post-elcap-upgrade.pkg
```

## Making the OS X upgrade package

As previously mentioned, we're going to use createOSXinstallPkg, so let's grab that:

``` bash
$ cd ~/src
$ git clone https://github.com/munki/createOSXinstallPkg.git
$ cd createOSXinstallPkg
```

And assuming your OS X Installer is saved to the usual place:

``` bash
$ sudo ./createOSXinstallPkg --pkg ../first-boot-pkg/post-elcap-upgrade.pkg --source "/Applications/Install OS X El Capitan GM Candidate.app"
```

createOSXinstallPkg will let you know how it's doing:

``` bash
Examining and verifying source...
----------------------------------------------------------------
InstallESD.dmg: /Applications/Install OS X El Capitan GM Candidate.app/Contents/SharedSupport/InstallESD.dmg
OS Version: 10.11
OS Build: 15A282b
----------------------------------------------------------------
Output path: /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg
Additional packages:
----------------------------------------------------------------
post-elcap-upgrade.pkg
----------------------------------------------------------------
Total additional package size: 1856 Kbytes
----------------------------------------------------------------
Checking available space on /Applications/Install OS X El Capitan GM Candidate.app/Contents/SharedSupport/InstallESD.dmg...
Creating package wrapper...
Creating MacOSXInstaller.choiceChanges...
----------------------------------------------------------------
Downloading and adding IncompatibleAppList pkg...
Downloading http://swcdn.apple.com/content/downloads/03/34/031-32728/f7ouzm6ipiy5h4c325qbantr81tw7o9yyi/OSX_10_11_IncompatibleAppList.pkg to /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg/Contents/Resources/OS X Install Data/OSX_10_11_IncompatibleAppList.pkg...
Writing index.sproduct to /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg/Contents/Resources/OS X Install Data/index.sproduct...
----------------------------------------------------------------
Copying InstallESD into package...
Mounting /Applications/Install OS X El Capitan GM Candidate.app/Contents/SharedSupport/InstallESD.dmg...
Copying additional packages to InstallESD/Packages/:
    Copying flat package ../first-boot-pkg/post-elcap-upgrade.pkg
Creating /private/tmp/tmp4hDxTs/dmg.BzTtzS/Packages/OSInstall.collection
Unmounting /Applications/Install OS X El Capitan GM Candidate.app/Contents/SharedSupport/InstallESD.dmg...
Creating disk image at /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg/Contents/Resources/InstallESD.dmg...
Preparing imaging engine…
Reading Protective Master Boot Record (MBR : 0)…
   (CRC32 $9A0557B7: Protective Master Boot Record (MBR : 0))
Reading GPT Header (Primary GPT Header : 1)…
   (CRC32 $39D58726: GPT Header (Primary GPT Header : 1))
Reading GPT Partition Data (Primary GPT Table : 2)…
   (CRC32 $F5D8C782: GPT Partition Data (Primary GPT Table : 2))
Reading  (Apple_Free : 3)…
   (CRC32 $00000000:  (Apple_Free : 3))
Reading EFI System Partition (C12A7328-F81F-11D2-BA4B-00A0C93EC93B : 4)…
...
   (CRC32 $B54B659C: EFI System Partition (C12A7328-F81F-11D2-BA4B-00A0C93EC93B : 4))
Reading disk image (Apple_HFS : 5)…
...............................................................................................
   (CRC32 $0A97BB61: disk image (Apple_HFS : 5))
Reading  (Apple_Free : 6)…
................................................................................................
   (CRC32 $00000000:  (Apple_Free : 6))
Reading GPT Partition Data (Backup GPT Table : 7)…
................................................................................................
   (CRC32 $F5D8C782: GPT Partition Data (Backup GPT Table : 7))
Reading GPT Header (Backup GPT Header : 8)…
.................................................................................................
   (CRC32 $A9B0AD1F: GPT Header (Backup GPT Header : 8))
Adding resources…
.................................................................................................
Elapsed Time:  1m 13.452s
File size: 6060448966 bytes, Checksum: CRC32 $613FF36A
Sectors processed: 13002104, 12518380 compressed
Speed: 83.2Mbytes/sec
Savings: 9.0%
created: /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg/Contents/Resources/InstallESD.dmg
----------------------------------------------------------------
Done! Completed package at: /Users/grahamgilbert/src/createOSXinstallPkg/InstallOSX_10.11_15A282b_custom.pkg
```

And voilla! You have a package that can be deployed by virtually any management tool (Munki in my case) that will make sure the latest version of Munki is also installed at the same time.