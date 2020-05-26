---
categories:
- Crypt
- Swift
- Python
date: "2015-12-03T13:10:49Z"
modified: null
title: Crypt 2 Alpha Release
---

A few months ago at PSU, Tom Burgin and Jeremy Baker [spoke about using Authorization Plugins](https://youtu.be/tcmql5byA_I?list=PLRUboZUQxbyVydhdMcxGGfEaZc2sFdQk8). I sat there watching this talk thinking about how cool it would be to use this method for Crypt. And then I had a go at it. And it was *hard*. So I put it to one side.

Then in November, I met up with Tom at MacTech. He very kindly donated a few hours of his time to get me started with re-writing Crypt as an authorization plugin in Swift. <!--more-->

Moving to an authorization plugin gives us a couple of advantages. The first is that this is the Apple-supported way of interacting with the machine before the user has completed login. Previously we had to use a Login Hook to launch things as the user was logging in if we wanted to run them as root - this has been deprecated for several releases of OS X, so it's a good time to move off. Secondly, we get access to the user's username and password, so it's a more streamlined process when enabling FileVault not needing to ask the user to enter their credentials twice.

{{< figure class="center" src="/images/posts/2015-12-03/crypt2.png" >}}

Please bear in mind this is an **alpha** release. You should not use this in production, but testing feedback is more than welcome. You can find out more on the [GitHub repo](https://github.com/grahamgilbert/crypt2).