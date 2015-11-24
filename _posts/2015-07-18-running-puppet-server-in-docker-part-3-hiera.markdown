---
layout: post
title: "Running Puppet Server in Docker Part 3: Hiera"
date: 2015-07-18 09:36:01 +0100
comments: true
categories: 
- Docker
- Puppet
- Hiera
---
In the previous [two](http://grahamgilbert.com/blog/2015/06/22/running-puppet-server-in-docker/) [parts](http://grahamgilbert.com/blog/2015/06/24/running-puppet-server-in-docker-part-2-r10k/#comment-2143364638), we went over how to get a basic Puppet Server up and running in Docker and how to deploy your modules using r10k. This time we'll assign some configuration to our nodes using [Hiera](http://docs.puppetlabs.com/hiera/latest/).

For a full explanation of what Hiera is, see the Puppetlabs documentation, but essentially, you are using a series of directories and files that are named in a particular way, and then specifying which is the most speccific to your node.<!-- more -->

Let's get things set up. First off, you need to tell your server what order it should be looking things up in. Restart the Puppet Server container when you've made the change. This is mine, yours will likely be different:

``` yaml /usr/local/docker/puppetserver/puppet/hiera.yaml
---
:backends:
  - yaml
:yaml:
  :datadir: /etc/puppet/environments/%{::environment}/hieradata/
:hierarchy:
  - "certs/%{::clean_certname}"
  - "osfamily/%{::osfamily}"
  - "virtual/%{::osfamily}/%{::virtual}"
  - "virtual/%{::virtual}"
  - common
```

From top to bottom:

* We're telling Hiera that we're using a yaml backend - you can in theory use anything to provide data to Hiera, but I've only ever used yaml.
* We're telling Hiera where to find the hierachy - we're keeping ours in our control repo, so we can make changes based on environment.
* And finally, we're specifying our hierachy. Anything that looks like ``%{::osfamily}`` is a value from Facter. This means we can apply configuration dynamically based on the node's values from Facter. Did that mean nothing to you? [Go and read this page before carrying on.](http://docs.puppetlabs.com/hiera/latest/hierarchy.html)

In your control repo, create the following files:

``` bash environment.conf
manifest = site.pp
modulepath = modules:site
```

``` bash site.pp
hiera_include('classes')
```

Woah, hold on - what just happened there? In three lines, we told Puppet where to find our ``site.pp`` file - the file that is read first during a Puppet run, and then in ``site.pp`` that is should include our classes from Hiera. Let's do that now. We're going to make our most general configuration - ``common.yaml`` that came at the bottom of ``hiera.yaml`` above.

``` yaml hieradata/common.yaml
---
classes:
  - puppet_run
"puppet_run::server_name": puppet.example.com
```

We want all of our clients to run Puppet periodically - so we've included the ``puppet_run`` class and have set the ``puppet_run::server_name`` variable. Where did we find that variable? All of a classes variables are [listed at the top of the file](https://github.com/grahamgilbert/puppet-puppet_run/blob/master/manifests/init.pp#L2).

But let's say we want Munki on all of our Macs. We don't want it being installed on Linux, so we need to be a bit more specific in our hierachy:

``` yaml hieradata/osfamily/Darwin.yaml
---
classes:
  - mac_admin::munki
  - mac_admin::munki::munkitools

mac_admin::munki::repourl: https://munki.example.com
mac_admin::munki::install_apple_updates: true
```

This will only be applied to nodes that have their ``osfamily`` fact equal to ``Darwin``.

Now all of that is commited to your control git repository, all that remains is to deploy it on your Puppet Server:

``` bash
$ r10k deploy environment -pv
```