---
categories:
  - Linux
  - Ubuntu
  - IRC
comments: true
date: "2013-10-13T00:00:00Z"
title: "ZNC: An IRC Bouncer"
---

Yes, it's true. The most interesting conversations in the Mac admin world take place using technology from the 1980's - [IRC](http://en.wikipedia.org/wiki/Internet_Relay_Chat) (##osx-server on [freenode](http://freenode.net/)). Those of you who know me will know that I'm borderline OCD. In this instance, my major annoyance was that I'd only get half of the conversation and I'd miss private messages when I had to put my laptop to sleep. I needed to somehow keep a persistient connection to IRC without having to sit infront of my computer 24/7.

I'd heard of IRC bouncers before - an app that runs on a server, saving the messages in the rooms you specify for you until you are able to read them, but always assumed they were much more difficult to set up than it turned out to be.

This is set up on a box running Ubuntu 12.04, with port 6666 opened on your firewall and forwarded to the box if you want to access it from outside the network. Mine is running on an [Amazon EC2 Micro instance](http://aws.amazon.com/free/) - available for free for one year if you don't already have a server to run it on.

Right, let's get started. All of these commands are to be run as your normal user (`graham` in this case - **not root**). First we're going to enable backports in Ubuntu. I like editing text files in `nano` so I'm going to install that first, but feel free to use Vi or whatever you like.

```bash
$ sudo apt-get install -y nano
$ sudo nano /etc/apt/sources.list
```

Find the two backports lines commented out (lines 44-45 on my test box) and unomment them.

```bash
deb http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ precise-backports main restricted universe multiverse
```

If you are using nano, hit `CTRL+O` and press return to save it, then `CTRL-X` to exit.

To install ZNC, issue the following command:

```bash
$ sudo apt-get update
$ sudo apt-get install -y znc/precise-backports znc-dbg/precise-backports znc-dev/precise-backports znc-extra/precise-backports znc-perl/precise-backports znc-python/precise-backports znc-tcl/precise-backports
```

<!--more-->

Thankfully there is a easy wizard to follow to configure ZNC. Below is a transcript of my settings, but feel free to adjust them to your tastes (make sure you are running this as your normal user, not sudo/root). Do not be scared by the masses of text, you have to type in very little.

```
$ znc --makeconf
[ ok ] Checking for list of available modules...
[ ** ] Building new config
[ ** ]
[ ** ] First let's start with some global settings...
[ ** ]
[ ?? ] What port would you like ZNC to listen on? (1025 to 65535): 6666
[ ?? ] Would you like ZNC to listen using SSL? (yes/no) [no]: yes
[ ** ] Unable to locate pem file: [/home/graham/.znc/znc.pem]
[ ?? ] Would you like to create a new pem file now? (yes/no) [yes]: yes
[ ok ] Writing Pem file [/home/graham/.znc/znc.pem]...
[ ?? ] Would you like ZNC to listen using ipv6? (yes/no) [yes]: no
[ ?? ] Listen Host (Blank for all ips):
[ ok ] Verifying the listener...
[ ** ]
[ ** ] -- Global Modules --
[ ** ]
[ ** ] +-----------+----------------------------------------------------------+
[ ** ] | Name      | Description                                              |
[ ** ] +-----------+----------------------------------------------------------+
[ ** ] | partyline | Internal channels and queries for users connected to znc |
[ ** ] | webadmin  | Web based administration module                          |
[ ** ] +-----------+----------------------------------------------------------+
[ ** ] And 12 other (uncommon) modules. You can enable those later.
[ ** ]
[ ?? ] Load global module <partyline>? (yes/no) [no]:
[ ?? ] Load global module <webadmin>? (yes/no) [no]:
[ ** ]
[ ** ] Now we need to set up a user...
[ ** ]
[ ?? ] Username (AlphaNumeric): grahamgilbert
[ ?? ] Enter Password:
[ ?? ] Confirm Password:
[ ?? ] Would you like this user to be an admin? (yes/no) [yes]: yes
[ ?? ] Nick [grahamgilbert]:
[ ?? ] Alt Nick [grahamgilbert_]:
[ ?? ] Ident [grahamgilbert]:
[ ?? ] Real Name [Got ZNC?]: Graham Gilbert
[ ?? ] Bind Host (optional):
[ ?? ] Number of lines to buffer per channel [50]: 1000
[ ?? ] Would you like to clear channel buffers after replay? (yes/no) [yes]: yes
[ ?? ] Default channel modes [+stn]:
[ ** ]
[ ** ] -- User Modules --
[ ** ]
[ ** ] +--------------+------------------------------------------------------------------------------------------+
[ ** ] | Name         | Description                                                                              |
[ ** ] +--------------+------------------------------------------------------------------------------------------+
[ ** ] | chansaver    | Keep config up-to-date when user joins/parts                                             |
[ ** ] | controlpanel | Dynamic configuration through IRC. Allows editing only yourself if you're not ZNC admin. |
[ ** ] | perform      | Keeps a list of commands to be executed when ZNC connects to IRC.                        |
[ ** ] +--------------+------------------------------------------------------------------------------------------+
[ ** ] And 22 other (uncommon) modules. You can enable those later.
[ ** ]
[ ?? ] Load module <chansaver>? (yes/no) [no]: yes
[ ?? ] Load module <controlpanel>? (yes/no) [no]:
[ ?? ] Load module <perform>? (yes/no) [no]:
[ ** ]
[ ?? ] Would you like to set up a network? (yes/no) [no]: yes
[ ?? ] Network (e.g. `freenode' or `efnet'): freenode
[ ** ]
[ ** ] -- Network Modules --
[ ** ]
[ ** ] +-------------+-------------------------------------------------------------------------------------------------+
[ ** ] | Name        | Description                                                                                     |
[ ** ] +-------------+-------------------------------------------------------------------------------------------------+
[ ** ] | chansaver   | Keep config up-to-date when user joins/parts                                                    |
[ ** ] | keepnick    | Keep trying for your primary nick                                                               |
[ ** ] | kickrejoin  | Autorejoin on kick                                                                              |
[ ** ] | nickserv    | Auths you with NickServ                                                                         |
[ ** ] | perform     | Keeps a list of commands to be executed when ZNC connects to IRC.                               |
[ ** ] | simple_away | This module will automatically set you away on IRC while you are disconnected from the bouncer. |
[ ** ] +-------------+-------------------------------------------------------------------------------------------------+
[ ** ] And 17 other (uncommon) modules. You can enable those later.
[ ** ]
[ ?? ] Load module <chansaver>? (yes/no) [no]: yes
[ ?? ] Load module <keepnick>? (yes/no) [no]: no
[ ?? ] Load module <kickrejoin>? (yes/no) [no]: no
[ ?? ] Load module <nickserv>? (yes/no) [no]: no
[ ?? ] Load module <perform>? (yes/no) [no]: no
[ ?? ] Load module <simple_away>? (yes/no) [no]: yes
[ ** ]
[ ** ] -- IRC Servers --
[ ** ] Only add servers from the same IRC network.
[ ** ] If a server from the list can't be reached, another server will be used.
[ ** ]
[ ?? ] IRC server (host only): irc.freenode.net
[ ?? ] [irc.freenode.net] Port (1 to 65535) [6667]:
[ ?? ] [irc.freenode.net] Password (probably empty):
[ ?? ] Does this server use SSL? (yes/no) [no]:
[ ** ]
[ ?? ] Would you like to add another server for this IRC network? (yes/no) [no]:
[ ** ]
[ ** ] -- Channels --
[ ** ]
[ ?? ] Would you like to add a channel for ZNC to automatically join? (yes/no) [yes]: yes
[ ?? ] Channel name: ##osx-server
[ ?? ] Would you like to add another channel? (yes/no) [no]: no
[ ?? ] Would you like to set up another network? (yes/no) [no]: no
[ ** ]
[ ?? ] Would you like to set up another user? (yes/no) [no]: no
[ ok ] Writing config [/home/vagrant/.znc/configs/znc.conf]...
[ ** ]
[ ** ] To connect to this ZNC you need to connect to it as your IRC server
[ ** ] using the port that you supplied.  You have to supply your login info
[ ** ] as the IRC server password like this: user/network:pass.
[ ** ]
[ ** ] Try something like this in your IRC client...
[ ** ] /server <znc_server_ip> +6666 grahamgilbert:<pass>
[ ** ] And this in your browser...
[ ** ] https://<znc_server_ip>:6666/
[ ** ]
[ ?? ] Launch ZNC now? (yes/no) [yes]: no
```

Still with me? One last thing to do - make sure ZNC starts and keeps running. We'll use Upstart (hat-tip to [@natewalck](https://twitter.com/natewalck/status/389345376811356160)).

```bash
$ sudo nano /etc/init/znc.conf
```

And pop in the following, replacing `sudo -u graham` with your own username.

```
# znc - IRC Bouncer

description "IRC Bouncer"

start on runlevel [2345]

stop on runlevel [016]

respawn
respawn limit 15 5

script
  exec sudo -u graham /usr/bin/znc
end script
```

Then finally start it up:

```bash
$ sudo start znc
```

Configuring each IRC client is different, but for Textual (my preferred client), it's pretty straightforward. Go to the Server menu and choose Add Server. Make the settings look like below, obviously replaing the hostname and password with the ones you chose.

{{< figure class="center" src="/images/posts/2013-10-13/textual_settings.png" >}}
