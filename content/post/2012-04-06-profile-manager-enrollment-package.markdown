---
categories:
- Lion
- Profle Manager
- Server
- Code
comments: true
date: "2012-04-06T00:00:00Z"
title: Profile Manager Enrollment Package
---
Over the past week or so, we had a need to enroll macs automagically with a Lion Profile Manager server. My first plan was to do what Charles Edge did in his recent [blog post](http://krypted.com/mac-os-x/automating-profile-manager-enrollment-through-deploystudio/) and use DeployStudio. Then I remembered another post by Charles on [/usr/bin/profiles](http://krypted.com/iphone/profile-manager-and-profiles/) and wondered if I could make a workflow that can be used throughout our deployment and system maintenance process - yup, the humble pkg, that can be popped into Munki for existing macs, installed with DeployStudio for imaging and pushed out with ARD if need be. 

[Get the code from GitHub](https://github.com/grahamgilbert/Profile-Manager-Enrollment)

Assuming you've got [The Luggage](https://github.com/unixorn/luggage) set up, first off you'll need your enrollment and trust profiles:

1.	Create a new enrollment profile
2. Give your enrollement profile a name
3. Download the trust profile
4. Download the enrollment profile

[{{< figure class="center" src="/images/posts/2012-04-06/profile_enrollment_and_trust-thumb.jpg" >}}](/images/posts/2012-04-06/profile_enrollment_and_trust-full.jpg)

If your attachments auto open, click cancel when you're asked if you want to install the profiles so they stay in ~/Downloads. Rename them to enroll.mobileconfig and trust.mobileconfig and pop them into the directory you cloned from GitHub. A quick `make pkg` and you've got your package.