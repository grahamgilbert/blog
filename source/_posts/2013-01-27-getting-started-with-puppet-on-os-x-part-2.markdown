---
layout: post
title: "Getting started with Puppet on OS X (part 2)"
date: 2013-01-27 09:30
comments: true
categories: 
- OS X
- Puppet
---
Before reading this post, you really need to read [part 1](http://grahamgilbert.com/blog/2013/01/25/getting-started-with-puppet-part-1/) - none of this will make sense without it!

Still with me? Let's do finally do something with Puppet. SSH into your Puppet Master (if it's IP has changed since you first did the setup, make sure you reflect this change in the Mac client's /etc/hosts file) and navigate to /etc/puppet and list the directory's contents:

	cd /etc/puppet
	ls -la

You'll see a few directories here - we're interested in two today - manifests and modules. Manifests will be where you describe your nodes, and the modules are the functional Puppet code.
<!-- more -->
Inside the manifests directory is site.pp - we're going to describe our node within this file. It's considered bad practice to keep everything in the site.pp file, but it will work for us. So, open up the site.pp file in your favourite editor (nano, pico, whatever), scroll down to the bottom and put in the following:

{% codeblock site.pp lang:ruby %}
node puppetclient {
    file {'puppettest':
      path    => '/tmp/puppettest',
      ensure  => present,
      mode    => 0640,
      content => "I'm a test file.",
    }
}
{% endcodeblock %}

Then on your client Mac:

	sudo puppet agent --test --group 0

And then magic happens! 

	sudo less /tmp/puppettest
	
Your file has appeared! Ok, admittedly this isn't particularly useful at the moment, but the same principle can be used to configure LaunchDaemons or distribute the company wallpaper for example.

You will get some moaning that Darwin isn't supported on Puppet Enterprise after Puppet has finished running. Don't worry about this, as I said in the first part, we're only using Puppet Enterprise as it's pre-built. 

Making a file isn't overly impressive. Any package installer or even ARD could do that. Puppet's magic lies in it's ability to maintain the system in the state you describe.

	sudo rm /tmp/puppettest
	ls -la /tmp

Now you've made sure the file isn't there, run Puppet again:

	sudo puppet agent --test --group 0

You'll see Puppet telling you that it's creating the file again:

	Notice: /Stage[main]//Node[puppetclient]/File[puppettest]/ensure: created
	Notice: Finished catalog run in 0.07 seconds
	
Now what happens if you change the content of the file on the client Mac? Enter ``sudo nano /tmp/puppettest`` into a terminal window on the client and change the contents of the file to something else like

	I won't have my strings pulled!
	
And then invoke Puppet again:

	sudo puppet agent --test --group 0
	
You now see Puppet correcting the file back to what we've described in the node's definition. (Once again, ignore the errors, they're down to using the pre-built VM again.)

{% codeblock %}
Notice: /Stage[main]//Node[puppetclient]/File[puppettest]/content: 
--- /tmp/puppettest	2013-01-27 10:51:43.000000000 +0000
+++ /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/puppet-file20130127-2683-19sd0ps-0	2013-01-27 10:51:50.000000000 +0000
@@ -1 +1 @@
-I won't have my strings pulled!
+I'm a test file.
\ No newline at end of file
{% endcodeblock %}

Victory! In the next part we'll make our admin user and ensure that it stays on the machine. In the mean time, have a play with changing the file through the Puppet Master - try changing it's mode or contents - or you could remove it by setting the ``ensure => present`` to ``ensure => absent``.
	
[Onwards to part 3!](/blog/2013/02/24/getting-started-with-puppet-on-os-x-part-3/)