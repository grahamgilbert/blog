---
layout: post
title: "Getting Started With Puppet on OS X (Part 3)"
date: 2013-02-24 14:59
comments: true
published: false
categories: 
- OS X
- Puppet
---
Before reading this post, you really need to read [part 1](http://grahamgilbert.com/blog/2013/01/25/getting-started-with-puppet-part-1/), [part 2](http://grahamgilbert.com/blog/2013/01/27/getting-started-with-puppet-on-os-x-part-2/) and most importantly my post on [building a Puppet Master with Vagrant](http://grahamgilbert.com/blog/2013/02/13/building-a-test-puppet-master-with-vagrant/). The Puppet Labs provided VM won’t cut it here, we need the latest version of Puppet on our Master. If you are using the same Mac / OS X VM that was previously hooked up to the Puppet Master VM, you will need to run the following command on the client - don’t worry, it will get new certificates from your very own Puppet Master:

	sudo rm -rf /var/lib/puppet/ssl
	
Make sure your test Mac is pointing to the right server - unless you’ve changed your Vagrantfile, your Puppet Master’s IP address will be 192.168.33.10 - you will need to change your test Mac’s /etc/hosts file to reflect this change.

__Updates from the previous post:__ Since the last post was published, Puppet version 3.1 has been released - the main bonus to Mac users is that the Puppet user and group are now created, so the manual Puppet run command is a little shorter. What was this:
	
	sudo puppet agent --test --verbose --group 0

Can now be shortened to:

	sudo puppet agent --test --verbose
	
As the Puppet user and group now exist, you no longer need to run Puppet as root. This creates another issue (the Puppet user is visible at the login screen despite it not being able to log in), but we'll get around that in this article. Regardless, you want to install [Puppet 3.1](http://downloads.puppetlabs.com/mac/). Back to the main event.

In this post, we’ll do something pretty much all Mac admins will need to do - set up their admin user. First thing’s first, create your admin user. I’ve called mine “Local Administrator”, with a short name of “ladmin” and the very imaginative passord of “password”. Next open up a Terminal window on your puppetclient Mac and issue the following command:

	sudo puppet resource user ladmin
	
You’ll see output similar to this:

{% codeblock site.pp lang:ruby %}
user { 'ladmin':
  ensure     => 'present',
  comment    => 'Local Admin',
  gid        => '20',
  groups     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin'],
  home       => '/Users/ladmin',
  iterations => '21881',
  password   => '401e3aa796b3bfff2c8e929a003b727be1bd548aa0f0b0e131f0d11f3953162be210200a70872734a28be747a933e12e2458ffdcc60d209eab9e006a9f4042dc883148070e6e8ad05f4a5e5d44bd0ddfc9494482f0d16c9d5eb1de086183db1b89df9982d2856eeed431d65e03ff99177c3185aa61bc926b1a0020c49621ddd8',
  salt       => '0c3cd42b97d0b0df45542fcb5961a2920f2fd6204aa151bf08d762d9dd44fd0c',
  shell      => '/bin/bash',
  uid        => '502',
}
{% endcodeblock %}

That looks suspiciously like Puppet code. Let's try it.

With the Vagrant based Puppet Master, the manifests file that previously lived at /etc/puppet/manifests is now located on your Mac at puppet/manifests (as is the modules folder, Vagrant takes care of linking it to the right place on the VM). Open up puppet/manifests/sites.pp in your favourite text editor (for the love of all that’s holy, please don’t use TextEdit. Try TextWrangler, or my current favourite [Chocolat](http://www.chocolatapp.com/)).

{% codeblock site.pp lang:ruby %}
node puppetclient {
	user { 'ladmin':
  		ensure     => 'present',
  		comment    => 'Local Admin',
  		gid    => '20',
  		groups     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin'],
  		home       => '/Users/ladmin',
  		iterations => '21881',
  		password   => '401e3aa796b3bfff2c8e929a003b727be1bd548aa0f0b0e131f0d11f3953162be210200a70872734a28be747a933e12e2458ffdcc60d209eab9e006a9f4042dc883148070e6e8ad05f4a5e5d44bd0ddfc9494482f0d16c9d5eb1de086183db1b89df9982d2856eeed431d65e03ff99177c3185aa61bc926b1a0020c49621ddd8',
  		salt       => '0c3cd42b97d0b0df45542fcb5961a2920f2fd6204aa151bf08d762d9dd44fd0c',
  		shell      => '/bin/bash',
  		uid        => '502',
	}
}
{% endcodeblock %}

Save it, and then back on your client perform a Puppet run:

	sudo puppet agent --test --verbose
	
Of course nothing has changed - that’s because your client’s configuration is how you have described it in site.pp. Try changing ladmin’s password in system preferences, then perform another Puppet run. You’ll see Puppet change the password right back.

Now we’ve got our Local Admin user working, it might be nice to hide it away from inquisitive users. The first step is to change our Local Admin’s UID to something lower than 500 - I like 404 (nerd joke), and then for good measure, we’ll move the home folder out of /Users and into /var.

{% codeblock site.pp lang:ruby %}
node puppetclient {
	user { 'ladmin':
  		ensure     => 'present',
  		comment    => 'Local Admin',
		gid        => '20',
  		groups     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin'],
  		home       => ‘/var/ladmin',
  		iterations => '21881',
  		password   => '401e3aa796b3bfff2c8e929a003b727be1bd548aa0f0b0e131f0d11f3953162be210200a70872734a28be747a933e12e2458ffdcc60d209eab9e006a9f4042dc883148070e6e8ad05f4a5e5d44bd0ddfc9494482f0d16c9d5eb1de086183db1b89df9982d2856eeed431d65e03ff99177c3185aa61bc926b1a0020c49621ddd8',
  		salt       => '0c3cd42b97d0b0df45542fcb5961a2920f2fd6204aa151bf08d762d9dd44fd0c',
  		shell      => '/bin/bash',
  		uid        => ‘404’,
	}
}
{% endcodeblock %}

That gets the home folder moved, now to actually hide the home folder. Add this just before the closing } (curly bracket) in your site.pp:

{% codeblock site.pp lang:ruby %}
exec {'Hide sub-500 users':
        command => "/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool TRUE",
        }
{% endcodeblock %}

When you perform a Puppet run, you’ll notice that your command is run every time, regardless of whether it needs to. We only really need to run that when we change our Local Admin user. To do that, we’ll change two lines. When the Admin User changes, we’ll send a signal to the exec, and we’ll change the exec to only run when it is told to.

{% codeblock site.pp lang:ruby %}
node puppetclient {
	user { 'ladmin':
  		ensure     => 'present',
  		comment    => 'Local Admin',
		gid        => '20',
  		groups     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin'],
  		home       => ‘/var/ladmin',
  		iterations => '21881',
  		password   => '401e3aa796b3bfff2c8e929a003b727be1bd548aa0f0b0e131f0d11f3953162be210200a70872734a28be747a933e12e2458ffdcc60d209eab9e006a9f4042dc883148070e6e8ad05f4a5e5d44bd0ddfc9494482f0d16c9d5eb1de086183db1b89df9982d2856eeed431d65e03ff99177c3185aa61bc926b1a0020c49621ddd8',
  		salt       => '0c3cd42b97d0b0df45542fcb5961a2920f2fd6204aa151bf08d762d9dd44fd0c',
  		shell      => '/bin/bash',
  		uid        => ‘404’,
  		notify     => Exec['Hide sub-500 users'],
	}
	
	    exec {'Hide sub-500 users':
        command => "/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool TRUE",
        refreshonly => true,
        }
}
{% endcodeblock %}

Save it, and perform a Puppet run on your client.You’ll notice that the defaults command is now only run when Puppet needs to modify the user.

Next time, we’ll be taking a look at Modules - pre-built bits of Puppet code that you can plug into your workflow to save you re-inventing the wheel.