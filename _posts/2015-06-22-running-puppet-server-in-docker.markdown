---
layout: post
title: "Running Puppet Server in Docker"
date: 2015-06-22 12:29:55 +0100
comments: true
categories:
- Docker
- Puppet
---
Back when I started using Puppet, configuring a Puppet Master could be pretty tricky as there were several moving parts (it was a Rack application, so needed to run behind something like [Passenger](https://www.phusionpassenger.com/) if you had any number of clients). Thankfully, the new [Puppet Server](https://github.com/puppetlabs/puppet-server) simplifies things massively - it's just one installation to get things working in a way that would be suitable for putting straight into production.

Over the next few posts, I'll take you through setting up the Puppet Server (running on Docker, naturally!), using r10k and git for managing your modules and using Hiera to configure your Macs - we'll apply some configuration to a Mac without writing a single line of Puppet code .

# Why?

You might well be thinking "why would I want to use Puppet?" After all, you've already got Munki. There are two main reasons I've chosen to go back to using a Puppet Server in conjunction with Munki.

1. It's nice to have a fallback. If I manage to do something stupid and nuke my Munki install, or my customers manage to do the same, I've got some way of getting the machines back under control.
2. "Free" SSL certs - this might not be a priority now, but it gives you an easy to to secure your Munki repository later on (which we may cover in a later post).<!-- more -->

# Let's get started

First off, you're going to need a Linux server with Docker installed. Installing it is beyond the scope of this post, but I do recommend you head over to [Digital Ocean](http://www.digitalocean.com/?refcode=ce1e0f3880e1) (disclaimer: referral link). They will get you up and running with a server with Docker pre-installed in under a minute for not much money.  I run mine on Ubuntu 14, but you can choose whichever flavour of Linux you prefer.

You will also need a DNS entry that points to your server's IP address. Whilst you could get away with fudging it by editing /etc/hosts, it's a lot of [faff](http://www.oxforddictionaries.com/definition/english/faff).

# Dockers, images and containers

I've already made a Docker image that has Puppet Server in it. Let's pull it down:

``` bash
$ docker pull grahamgilbert/puppetserver
```

And fire it up:

```
$ docker run -d --name=puppetserver \
-e PUPPETSERVER_JAVA_ARGS="-Xms384m -Xmx384m -XX:MaxPermSize=256m" \
-p 0.0.0.0:8140:8140 \
-h puppet.yourdomain.com \
grahamgilbert/puppetserver
```

You will need to change the amount of memory assigned to the puppet server depending on how much memory is in your actual server before going to production but for now, 384mb will be fine as we're just setting things up.

BUT there are a few things that we need to persist otherwise our server won't be very useful. First off, let's attach to the container so we can have a look around:

```
$ docker exec -t -i puppetserver bash
```

You'll be looking at a bash prompt now. First off, check that ``/etc/puppet`` and ``/etc/puppetserver`` have *stuff* in them. What's in there isn't important at this stage. We also need to run the Puppet client on the server to move some supporting files in place. We first need to enable auto signing of certificates in ``/etc/puppet/puppet.conf`` (we'll cover this more later):

``` bash /etc/puppet/puppet.conf
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
autosign = true
```

And then exit the container, stop it and start it up again:

``` bash
$ exit
$ docker stop puppetserver
$ docker start puppetserver
```

Take a look at the container's logs - Puppet Server can take a few seconds to be ready, so look for the line that says it's ready to accept connections:

``` bash
$ docker logs puppetserver
```

When it's ready, enter the container again and run the puppet agent.

``` bash
$ docker exec -t -i puppetserver bash
$ puppet agent -t
```

Provided that ran with no errors, we can exit out of the container.

``` bash
$ exit
```

We're now going to copy the parts we need to persist to the file system of the host machine - I like to keep my docker related things in ``/usr/local/docker`` but it's up to you.

```
$ mkdir -p /usr/local/docker/puppetserver
```

We're going to use ``docker cp`` to copy out of our container and onto our host filesystem. We want the configuration directories, any custom gems we install (required if we want to use modules such as [managedmac](https://github.com/dayglojesus/managedmac)), as well as the SSL certificates and some other supporting files (these aren't technically required, but will save having to run ``puppet agent -t`` after the container starts every time we update).

``` bash
$ docker cp puppetserver:/etc/puppetserver /usr/local/docker/puppetserver/
$ docker cp puppetserver:/etc/puppet /usr/local/docker/puppetserver/
$ docker cp puppetserver:/var/lib/puppet/ssl /usr/local/docker/puppetserver/lib/
$ docker cp puppetserver:/var/lib/puppet/lib /usr/local/docker/puppetserver/lib/
$ docker cp puppetserver:/var/lib/puppet/jruby-gems /usr/local/docker/puppetserver/
```

Now we're ready to run for real. Just a small piece of configuration to make our lives easier whilst we're testing - enabling auto signing of certificates. By default you will need to sign a certificate for each client that tries to connect to your puppet master. Eventually we will want to sign certificates using some sort of external inventory service (I like Sal, but there are also connectors for Web Help Desk), but for now we'll leave our configuration that tells Puppet to sign every certificate unconditionally.

``` bash
$ nano /usr/local/docker/puppetserver/puppet/puppet.conf
```

And make sure your ``puppet.conf`` looks like:

``` bash /usr/local/docker/puppetserver/puppet/puppet.conf
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
pluginsync=true
[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
autosign = true
```

Now all that remains is to fire up our final container and then we can hook up a client.

``` bash
# remove our old container
$ docker rm -f puppetserver
$ docker run -d \
  --name="puppetserver" \
  --restart="always" \
  -v /usr/local/docker/puppetserver/puppet:/etc/puppet \
  -v /usr/local/docker/puppetserver/puppetserver:/etc/puppetserver \
  -v /usr/local/docker/puppetserver/lib/ssl:/var/lib/puppet/ssl \
  -v /usr/local/docker/puppetserver/jruby-gems:/var/lib/puppet/jruby-gems \
  -v /usr/local/docker/puppetserver/lib/lib:/var/lib/puppet/lib \
  -p 0.0.0.0:8140:8140 \
  -e PUPPETSERVER_JAVA_ARGS="-Xms384m -Xmx384m -XX:MaxPermSize=256m" \
  -h puppet.yourdomain.com \
  grahamgilbert/puppetserver
```

Let's make sure it's finished starting up.

``` bash
$ docker logs -f puppetserver
```

This works like tail would. Hit ctrl-c to exit once it says it's ready to go.

# Hook up a client

You're going to need Puppet, Facter and Hiera on your client Mac. Head over [http://downloads.puppetlabs.com/mac](http://downloads.puppetlabs.com/mac) and download and install the latest version of Puppet, Facter and Hiera.

If we just ran Puppet now, it would use the Mac's hostname as the certificate name (the unique identifier for the machine). If you have reliable hostnames, that will probably do you. I prefer to use the machine's serial number (lower case, because that's what Puppet likes). We'll automate this in a later post, but for now we can do it by hand:

``` bash /etc/puppet/puppet.conf
[main]
server=puppet.yourdomain.com
certname=abc123
```

All that's left now is to run puppet on the client:

``` bash
$ puppet agent -t --waitforcert 20
```

In a later post, we will look at how we can use r10k to manage our modules and use Hiera to configure our clients without touching a line of Puppet code.
