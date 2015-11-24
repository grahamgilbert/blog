---
layout: post
title: "Running Puppet Server in Docker Part 2: r10k"
date: 2015-06-24 14:49:31 +0100
comments: true
categories:
- Docker
- Puppet
- r10k
---

Last time we got our Puppet Server up and running - now we need to put some Puppet modules on it so we can use it.

To do that, we're going to use r10k. It's a tool that uses a control git repository that contains something called a puppetfile- a file that lists all of the puppet modules you want to use, either from the puppet forge or from git repositories. You may want to keep this module private by using a paid account on GitHub if your configuration contains secrets, but  it doesn't have to be - mine doesn't have anything particularly sensitive in, so here it is: [grahamgilbert/personal-puppet](https://github.com/grahamgilbert/personal-puppet). <!-- more -->

## The Control module

Puppet recommends the use of environments - a way of separating your clients into groups - usually this is test and production groups. r10k uses git branches to determine which environments you have, so we're going to set up our repository. The default branch is called ``master``, but we want ours to be called ``production`` - Github has some excellent [documentation](https://help.github.com/articles/setting-the-default-branch/) on the subject. I recommend accepting GitHub's suggestion of putting a README in your repository so you can clone it right away.

## The Puppetfile

Now we've got our control repo set up, we can clone it so we can work on it.

```
$ git clone https://github.com/yourusername/yourcontolrepo
```

If you're familiar with Puppet, this will be familiar - an environment is what you would have once put at ``/etc/puppet`` - the only change is that you can override options on a per-environment basis by using ``environment.conf``. In my control repo, I have a default manifest at the top of the environment rather than in ``manifests`` for example. ([more information](https://docs.puppetlabs.com/puppet/latest/reference/config_file_environment.html))

At its simplest, a Puppetfile is just a list of modules we want to use. As we're just starting off, we can use pre-built ones from GitHub and the forge. We're going to get Munki installed on a client, so we'll use my MacAdmin module. One thing to note is that r10k won't resolve dependencies for you, so be sure to specify any modules the module you need. A simple Puppetfile is below:

``` ruby
mod 'mac_admin',
    :git => 'https://github.com/grahamgilbert/puppet-mac_admin'

mod 'mac_profiles_handler',
    :git => 'https://github.com/keeleysam/rcoleman-mac_profiles_handler'

mod 'mac_facts',
    :git => 'https://github.com/grahamgilbert/grahamgilbert-mac_facts.git'

mod 'repository',
    :git => 'https://github.com/boxen/puppet-repository'

mod 'outset',
    :git => 'https://github.com/grahamgilbert/puppet-outset'

mod 'stdlib',
    :git => 'https://github.com/puppetlabs/puppetlabs-stdlib'
```

## Configuring r10k

The next piece of the puzzle is to set up r10k to download our repository. I'm running r10k directly on my Docker host, but this could easily be (and probably should be) put into a Docker container. First off, let's get r10k installed:

```bash
$ gem install r10k
```

r10k get's in configuration from ``/etc/r1ok.yaml``, so let's create that:

``` yaml /etc/r10k.yaml
# The location to use for storing cached Git repos
:cachedir: '/var/cache/r10k'

# A list of git repositories to create
:sources:
  # This will clone the git repository and instantiate an environment per
  # branch in /etc/puppet/environments
  :personal-puppet:
    remote: 'https://github.com/yourusername/yourcontrolrepo'
    basedir: '/usr/local/docker/puppetserver/puppet/environments'

```

## Puppet Conf

The final piece of configuration for today will be to set our Puppet Server to use environments. Add the following to ``/usr/local/docker/puppetserver/puppet/puppet.conf``:

``` ini
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
environmentpath=$confdir/environments
pluginsync=true

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
autosign = true
environmentpath = $confdir/environments

```

## Gimmie some modules

We're ready to get some modules installed on the Puppet Server:

``` bash
$ r10k deploy environment -pv
```

You'll see all of the modules you specified in your Puppetfile download theselves to the right place. But of course, we're not quite ready to use this for applying configuration to our Macs yet - we have modules, but we've not applied the config to specific machines. In the next post we'll cover how we use Hiera to do this.
