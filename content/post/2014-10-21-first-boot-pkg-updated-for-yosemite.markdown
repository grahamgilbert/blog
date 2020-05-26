---
categories:
- OS X
- Python
- Deployment
comments: true
date: "2014-10-21T11:50:28Z"
title: first-boot-pkg updated for Yosemite
---
It seems like Yosemite introduced an [undocumented change](https://github.com/munki/createOSXinstallPkg#further-note-on-additional-packages-and-yosemite) that requires any packages that are added an OS X installer (e.g. Netinstall or createOSXinstallPkg) be distribution style packages, or you get a nasty failure acompanied by one of the most unhelpful error messages ever. 

To fix this, [first-boot-pkg](https://github.com/grahamgilbert/first-boot-pkg) now builds distribution style packages.