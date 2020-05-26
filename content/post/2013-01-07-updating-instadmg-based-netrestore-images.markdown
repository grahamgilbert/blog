---
categories:
- instadmg
- netrestore
- deployment
comments: true
date: "2013-01-07T00:00:00Z"
title: Updating InstaDMG based NetRestore images
---
This probably isn't news to anyone else, but I made a discovery last week that will save me a fair bit of time.

Whilst staring at System Image Utility after yet another change to the build, I thought that there must be a better way of doing this, bearing in mind that the basic InstaDMG process is:

- Install the OS
- Install Packages
- __Make a read-only DMG__
- __Prep the DMG for ASR__

And SIU's process is:

- __Make a read-only DMG__
- __Prep the DMG for ASR__
- Copy it into a writable disk image with a stripped down OS to restore the image.

So, two steps are duplicated. This inefficiency must be stopped!

After a 30 second hunt in the NetInstall.dmg file that SIU spits out, I saw a file called System.dmg in the Packages folder - sure enough, it was my InstaDMG image. I replaced it with my new build, and it worked flawlessly. 

If your new image is larger than the one you're replacing, you just need to expand the NetInstall.dmg image to a size large enough to accomodate the new image.

	hdiutil resize -growonly -size 15g /path/to/your/NetRestore.nbi/NetInstall.dmg

Replace the 15g with whatever size you want, 15 GB was plenty to accomodate my updated image.