+++
date = 2020-07-16T13:00:00Z
lastmod = 2020-07-16T13:00:00Z
title = "Managing macOS Profiles with Configuration Management in 2020"
+++

macOS 11 has brought two, small on their own, but significant changes to how we are able to manage macOS. Today we’ll talk about the first: Profiles.

## Background

Back in macOS 10.11 El Capitan, Apple introduced System Integrity Protection. This was the first time the root user wasn’t able to do whatever it wanted on macOS - certain files and directories could only be modified by Apple blessed methods (or by disabling or bypassing the protection, but I digress).

Early on in the 10.13 cycle, User Approved MDM was introduced. This was the first time MDM was required since its introduction in Mac OS X 10.7 Lion. Kernel extensions either needed to be approved by a user manually or whitelisted via profile that could only be delivered with a User Approved MDM enrollment. Since kernel extensions continue to be a key cause of instability on macOS, as well as a potential security issue since they provide direct access to the kernel, this seems like a good move on the part of Apple - that is, unless you relied on deploying kernel extensions for key functionality and hadn’t set up an MDM yet.

Things remained relatively stable on this front for a couple of years until the release of macOS 10.15 Catalina.

## Managing profiles with Configuration Management

Most configuration management tools operate largely the same way when it comes to managing profiles on macOS:

- The profile is written out locally on disk.
- Several attributes are checked to see if the profile is installed and current (such as profile identifier and uuid).
- Then if the profile is out of date or missing, it is installed via the profiles binary.

This worked really well. We could dynamically generate profiles, easily making a unique profile per device if we needed to.

Catalina brought one change that many hoped wouldn’t happen - a warning that installing profiles locally via the profiles command line tool would be removed in a future release of macOS.

> WARNING: In the future, some features in this tool may be removed in favor of using user approved, high level UI to install configuration profiles. Clients should instead use the Profiles System Preferences pane to install configuration profiles.

It turned out that future release of macOS was the next major release. In macOS 11, the only method of installing profiles that doesn’t involve user interaction is via MDM.

The problem with the method most configuration management tools work is that all the logic is client side. The only way to do this with MDM in this scenario would be to have the client interact with the MDM’s API directly - and that is assuming that you can do this both securely (you definitely do not want one set of credentials deployed to all of your endpoints that has god level access to your MDM) and that your MDM has a suitable API at all.

Fortunately not all configuration management tools operate the same way. My organization uses [Puppet](https://puppet.com/), which roughly works like:

- Facts (small pieces of information about the system) are generated by the client and sent to the server.
- The server then uses this information to calculate our desired state of the client.
- The desired state is sent to the client and the device performs any required correction.

The advantage of this method for our purposes is that the server can also run code to manipulate the data the data it receives from the client. So we could also send a profile to our MDM at this point if we need to - without having keys to the MDM’s API on the client device.

So that’s problem number one solved. The next is to have a suitable API for your MDM. If you use a commercial MDM, you either have one or you don’t - you can’t change it beyond making feature requests to your vendor.

When my employer was selecting an MDM for our macOS devices, we spoke to many vendors. In the end we wound up staying true to our open source roots and went with [MicroMDM](https://micromdm.io/). I’m not going to lie, it scared the absolute poop out of me not having vendor support for this protocol I barely understood.

But as time went on, my team and I understood it more and became committers to the project, and ended up writing [MDMDirector](https://github.com/mdmdirector/mdmdirector) to help us orchestrate MicroMDM more effectively.

With this flexibility and the tools we had written, we now had our API to manage profiles with Puppet on macOS 11.

## Conclusion

This route definitely isn’t for everyone - running your own MDM is a great undertaking. But, with the right MDM and configuration management tools, it is still possible to manage profiles effectively with MDM.

If your MDM vendor doesn’t offer a suitable API, now is the time to get your feature requests in. If you are running Puppet and MicroMDM + MDMDirector (or an MDM with a compatible API), you can find the Puppet module we wrote on GitHub.

- [MicroMDM](https://micromdm.io/)
- [MDMDirector](https://github.com/mdmdirector/mdmdirector)
- [puppet-mac_profiles_handler](https://github.com/macadmins/puppet-mac_profiles_handler/)