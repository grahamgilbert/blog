---
title: High Sierra and my open source tools
date: 2017-06-07T10:12:05-07:00
layout: post
categories:
 - Open source
 - Imagr
 - Sal
 - Crypt
---

With this week's release of the first beta of High Sierra, I wanted to quickly update everyone on the current status of the tools I've released, and where I see the future going for them.

## Sal

Sal appears to work fine on High Sierra. Some of the external scripts may need updating, but right now I'm not seeing anything that's broken. I don't see anything changing in this regard.

## Crypt

Amazingly, the way we interact with FileVault as admins seems to not have changed at all, so Crypt has been reported to work perfectly (I will confirm when I get back to my testing computers that I don't mind nuking). Apple has had a habit of wiping out the authorization database for basically every update during Sierra's life, so this isn't really a surprise. Wither managing the entries with your configuration management tool, or simply reinstalling the package will get things working again.

Now we know it works, I will be pushing ahead with migrating it to Swift 3 so it can be built on a modern version of Xcode. If anyone wants to help with this effort, [please help out on the PR](https://github.com/grahamgilbert/crypt2/pull/38).

## Imagr

Imagr currently works, but is only able to restore HFS+ images, due to a limitation in `asr`. I don't see this restriction changing any time soon, so I would strongly suggest those who currently image to consider moving to a different workflow. At this time, all other functions of Imagr (running scripts, installing packages) are expected to continue functioning as they presently do.

If you use these tools, I really need help testing them. 10.13 has brought about so many changes that we need to be extra vigilant testing them. Even if you can't code, bug reports are really valuable.
