+++
date = 2020-09-21T13:00:00Z
lastmod = 2020-09-21T13:00:00Z
title = "Apple Silicon in Enterprise"
+++

This weekend I was browsing LinkedIn and I saw an article linked to in [Computerworld](https://www.computerworld.com/article/3575489/there-s-something-in-the-ipad-air-for-enterprise-it.html) about how Apple's new A14 chip would be amazing for enterprise.

My initial reaction was surprise, since most enterprises couldn't care less about the CPU in the device.

Of course, battery gains will be welcomed by end users. Improved performance would be nice, but the majority of user's entire computing experience is their web browser, so local performance for a huge number of people is becoming less relevant. But Apple Silicon will bring in other changes that will (at least initially) introduce new challenges for the use of macOS in the enterprise.

## Virtualization

During the launch of Apple Silicon during WWDC 2020, Apple touted the performance of virtualization on the new chips. What they didn't mention is that the guest OS will almost certainly need to be able to run on Apple Silicon. So at the moment if you need to run Windows, will be running the [ARM version of Windows 10](https://docs.microsoft.com/en-us/windows/uwp/porting/apps-on-arm) - so along with hoping that your macOS apps are compatible with Rosetta 2 (which, to be fair seems like the majority right now), you need to ensure your Windows apps also work on the ARM variant of that operating system.

## macOS Big Sur

Any security conscious organization that is running macOS should of course already be preparing to deploy Apple's latest operating system soon after it's release, but thanks to the myth that Apple fully patches anything other than the currently shipping operating system, many organizations are only just making the move to Catalina. If your users will demand the latest and greatest hardware with Apple Silicon inside, you should absolutely be testing macOS Big Sur, not only on your current Intel machines, but also on a [Developer Transition Kit](https://developer.apple.com/programs/universal/).

## Custom apps

If your organization delivers internal software that's not signed (really, sign your code), you may hit unexpected issues on Apple Silicon devices. macOS will not run unsigned code that's built on Apple Silicon devices - fortunately there is now a method to sign code on an ad-hoc basis, but this will inevitably catch some out.

## Conclusion

Apple Silicon will definitely bring some interesting changes for Enterprise (largely around security), but we cannot discount the potential difficulties this migration will introduce for many organizations.
