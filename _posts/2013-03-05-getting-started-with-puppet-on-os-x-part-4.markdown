---
layout: post
title: "Getting Started With Puppet on OS X (Part 4)"
date: 2013-03-05 14:59
comments: true
categories: 
- OS X
- Puppet
---
We've made quite a bit of progress with our Puppet install. We've already made Puppet do something useful with setting up an admin user, but let's get back to being lazy - let's get someone else to write the code.

Before reading this post, you really need to read [part 1](http://grahamgilbert.com/blog/2013/01/25/getting-started-with-puppet-part-1/), [part 2](http://grahamgilbert.com/blog/2013/01/27/getting-started-with-puppet-on-os-x-part-2/) and [part 3](http://grahamgilbert.com/blog/2013/02/24/getting-started-with-puppet-on-os-x-part-3/) of the series.

Modules are little pre-built bits of Puppet code. They're a good example of Puppet's philosophy of convention over configuration - Puppet will assume your modules follow a set pattern. We'll be using two of the available folders in modules today: files and manifests. Files are static files that Puppet will copy over to our client machine, and manifests will contain the Puppet code we've previously been putting into ``/etc/puppet/manifests/site.pp`` - whilst it's been easy to put code into this file, it can become unwieldy when you have a few nodes to manage.

There are also loads of pre-built modules on the [Puppet Forge](http://forge.puppetlabs.com/) - it's one of these modules we'll be using today.<!-- more -->

Assuming you're still using the Vagrant-based Puppet Master from [part 3](http://grahamgilbert.com/blog/2013/02/24/getting-started-with-puppet-on-os-x-part-3/), cd into the directory you've cloned the repository to, issue a ``vagrant up`` command. Once you've booted the VM, we need to SSH into it. 

	vagrant ssh

Puppet provides a handy tool to manage modules - ``puppet module``. To install the [mac_profiles_handler by Ryan Coleman](http://forge.puppetlabs.com/rcoleman/mac_profiles_handler), tap in:

	sudo puppet module install rcoleman/mac_profiles_handler
	
Pretty straightforward syntax there - the person who wrote the module comes before the slash, and the name of the module after it. You'll see some bumph about Puppet downloading the module, and if the author has specified any dependency on other modules, they'll be downloaded as well.

If you switch back to your Mac and look in the folder you cloned the vagrant-puppetmaster git repository into (mine is at ``~/src/Mine/blog-post``), you'll see the module you just installed in the ``puppet/modules`` directory.

{% img /images/posts/2013-03-05/mac_profiles_handler.png %}

Feel free to have a nose around to get the general structure for what a Puppet module can look like. It's ok, I'll wait.

Time for us to make our own module. In ``puppet/modules`` create a folder called ``my_super_module``. Within that, make ``files`` and ``manifests`` directories.

{% img /images/posts/2013-03-05/my_super_module.png %}

Next, grab [this simple configuration profile](/images/posts/2013-03-05/com.grahamgilbert.vpn.mobileconfig) I made. It configures a VPN connection - it's unsigned, so you can see what you're installing on your test Mac if you'd like. Place this .mobileconfig file in ``puppet/modules/my_super_module/files``. Or, if you'd rather, you can make your own for something else - configuring WiFi is pretty handy - I made this one in two minutes using [iPhone Configuration Utility](http://support.apple.com/kb/dl1465), but you can also make them with Profile Manager (I would recommend making them unsigned though, but that's outside the scope of this article).

For the actual meat of our module, we need some Puppet code. In your favourite text editor (please remember, not TextEdit!), create ``puppet/modules/my_super_module/init.pp``, and make it look like the following:

{% codeblock puppet/modules/my_super_module/init.pp lang:ruby %}
class my_super_module {
    mac_profiles_handler::manage { 'com.grahamgilbert.vpn':
      ensure       => present,
      file_source  => 'puppet:///modules/my_super_module/com.grahamgilbert.vpn.mobileconfig',
    }
}
{% endcodeblock %}

There are a few bits we've not seen before here:

	ensure => present,

We're simply telling puppet that we want to make sure this profile is always installed. If it's missing, re-install it. If we set this to ``ensure => absent``, we'd be telling Puppet to remove the profile. If we wanted to simply update the profile, we'd just replace the mobileconfig file (this module will be aware of the change and update the installed profile).

	file_source  => 'puppet:///modules/my_super_module/com.grahamgilbert.vpn.mobileconfig',
	
This is referring to the file in our module. The important bit is ``puppet:///`` with three slashes. That point to the server we're currently running on (and also makes our module portable to other servers). We don't need to do any other configuration to get Puppet serving this file now, as it expects to serve static files out of the ``files`` directory.

As we are using the built in web server for our Puppet Master, we need to restart the puppetmaster service to let it know about our new module. When you're on the Mac side, it's easiest just to reload the whole server:

	cd ~/src/wherever/your/code/is
	vagrant reload

Time to test it. Fire up your test Mac or your VM (if you need to configure it, please look at the [last post](http://grahamgilbert.com/blog/2013/02/24/getting-started-with-puppet-on-os-x-part-3/), I'm assuming it's still set up), and perform a Puppet run:

	sudo puppet agent --test

Wait! Nothing happened. That's because we've not told the Puppet Master to apply this particular module to our client Mac.

Make your ``puppet/manifests/site.pp`` look like this:

{% codeblock puppet/manifests/site.pp lang:ruby %}
node puppetclient {
    include my_super_module
}
{% endcodeblock %}

All we're doing here is telling Puppet to include our module with the default settings (as we didn't make any settings that can be changed - once again, outside the scope of this post). Splitting your code into modules not only allows you to share them with others if you wish, but also means you only need to change your code once and have it affect all of your applicable nodes.

Anyway, save your ``site.pp`` and perform another run on your client:

	sudo puppet agent --test
	
And now you'll see something along the lines of:

{% codeblock %}
Info: Retrieving plugin
Notice: /File[/var/lib/puppet/lib/puppet]/ensure: created
Notice: /File[/var/lib/puppet/lib/puppet/provider]/ensure: created
Notice: /File[/var/lib/puppet/lib/puppet/provider/profile_manager]/ensure: created
Notice: /File[/var/lib/puppet/lib/puppet/provider/profile_manager/osx.rb]/ensure: defined content as '{md5}48a098b58bf3fdf38f32a0261026fa59'
Notice: /File[/var/lib/puppet/lib/puppet/type]/ensure: created
Notice: /File[/var/lib/puppet/lib/puppet/type/profile_manager.rb]/ensure: defined content as '{md5}578a75ebe7f9972c7f49f8c5d4e1ad43'
Notice: /File[/var/lib/puppet/lib/facter]/ensure: created
Notice: /File[/var/lib/puppet/lib/facter/profiles.rb]/ensure: defined content as '{md5}54c12303c601579fb2282304363c8425'
Info: Loading facts in /var/lib/puppet/lib/facter/profiles.rb
Info: Caching catalog for puppetclient
Info: Applying configuration version '1362471535'
Notice: /Stage[main]/My_super_module/Mac_profiles_handler::Manage[com.grahamgilbert.vpn]/File[/var/lib/puppet/mobileconfigs]/ensure: created
Notice: /Stage[main]/My_super_module/Mac_profiles_handler::Manage[com.grahamgilbert.vpn]/File[/var/lib/puppet/mobileconfigs/com.grahamgilbert.vpn]/ensure: defined content as '{md5}48232db3a25fd851d1b1c7ec7c9557c8'
Info: /Stage[main]/My_super_module/Mac_profiles_handler::Manage[com.grahamgilbert.vpn]/File[/var/lib/puppet/mobileconfigs/com.grahamgilbert.vpn]: Scheduling refresh of Exec[remove-profile-com.grahamgilbert.vpn]
Notice: /Stage[main]/My_super_module/Mac_profiles_handler::Manage[com.grahamgilbert.vpn]/Exec[remove-profile-com.grahamgilbert.vpn]: Triggered 'refresh' from 1 events
Notice: /Stage[main]/My_super_module/Mac_profiles_handler::Manage[com.grahamgilbert.vpn]/Profile_manager[com.grahamgilbert.vpn]/ensure: created
Info: Creating state file /var/lib/puppet/state/state.yaml
Notice: Finished catalog run in 1.57 seconds
{% endcodeblock %}

And if you look in System Preferences, you'll see the Profiles icon has appeared, and that your profile has been installed.

{% img /images/posts/2013-03-05/profiles.png %}

And in the Network pane, your VPN connection has been configured:

{% img /images/posts/2013-03-05/vpn.png %}

Next time, we'll look at using Facter to make our code a little more intelligent. As ever, comments, corrections and general abuse is welcome. 

(Not the abuse, that's not nice.)