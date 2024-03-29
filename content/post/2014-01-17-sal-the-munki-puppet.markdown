---
categories:
- OS X
- Munki
- Python
- Puppet
comments: true
date: "2014-01-17T10:51:46Z"
title: 'Sal: The Munki Puppet'
---
At [pebble.it](http://pebbleit.com), we always wanted to have an easy dashboard to look at to visualise the information we could collect from Puppet and Munki. We tried a few options, but didn't like any of them, so we made our own. 

Say hi to Sal - the Munki Puppet. It's a multi-tenanted reporting solution for Munki and optionally, Facter.  You can find all of the details [over on GitHub](https://github.com/grahamgilbert/sal), including installation instructions and a package to send out to your clients.

{{< figure class="center" src="/images/posts/2014-01-17/Sal.png" >}}

There is a plugin system built in to Sal, and over the next few days I will have a couple of posts covering how to make your own.