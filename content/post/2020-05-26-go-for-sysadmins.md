+++
date = 2020-05-26T00:00:00Z
lastmod = 2020-05-26T00:00:00Z
title = "Go for SysAdmins"
+++

For Mac admins using Python to perform scripting duties, it's impending departure from the default install of macOS should be encouraging them to look at alternatives.

One option that is probably the easiest, is shipping your own installation of Python 3. This however isn't without it's drawbacks. You need to mantain and deploy an entire Python 3 runtime. Tools such as Greg Neagle's [Relocatable Python](https://github.com/gregneagle/relocatable-python) have made this easier, but it still remains a dependency for any tool you write. Shell and zsh are options for very basic scripts. What about for scripts that need a more advanced language?

If you are just working on macOS, Swift is a very good option. It has access to system frameworks, and is a single binary. This means that your dependencies are bundled up with your script in a single executable.

But what if you are working cross platform? [Go](https://golang.org/) support macOS, Windows and Linux. Go doesn't offer an easy way to access the native macOS API's, so if you desperately need to access those, Go might not be the best option. But but for many System Administration tasks, Go is an excellent option that, like Swift, compiles to a single binary, and on macOS is able to be signed and notarized.

## The problem

Let's take a common problem in large, cross platform environments - having two or three sets of instructions for helpdesk to follow for your various operating systems. Let's say we want to build a tool that will download and install OS updates for both macOS and Windows, so we only need to train our helpdesk team on one tool.

Just starting out with Go? I definitely suggest you run through a few parts of the (Go Tour)[https://tour.golang.org/welcome/1] to familiarize yourself with the differences between Go and languages you have used before.
