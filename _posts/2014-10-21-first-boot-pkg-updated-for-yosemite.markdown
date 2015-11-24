---
layout: post
title: "first-boot-pkg updated for Yosemite"
date: 2014-10-21 11:50:28 +0100
comments: true
categories: 
- OS X
- Python
- Deployment
---
It seems like Yosemite introduced an [undocumented change](https://github.com/munki/createOSXinstallPkg#further-note-on-additional-packages-and-yosemite) that requires any packages that are added an OS X installer (e.g. Netinstall or createOSXinstallPkg) be distribution style packages, or you get a nasty failure acompanied by one of the most unhelpful error messages ever. 

To fix this, [first-boot-pkg](https://github.com/grahamgilbert/first-boot-pkg) now builds distribution style packages.