---
categories:
- Docker
- Deployment
- OS X
comments: true
date: "2015-04-22T07:07:23Z"
title: Getting started with BSDPy on Docker
---

Have you heard of Docker, but think it all sounds a bit mystical and exotic? Then this is the post for you! Before we begin, you're going to need a machine (or a VM, either on your machine or on a server) with Ubuntu 14.04 LTS installed on it. You can install Docker on many other operating systems, but I use Ubuntu, so we're using that. Your Ubuntu box will also need a real IP address - if you are using VMware Fusion, this will be a Bridged Network Adapter - adjust the terminology if you're using a different virtualization tool. You don't need to worry about giving your machine a static IP unless you want to - Macs will NetBoot just fine when they're on the same subnet. <!--more-->

## Baby Steps

Our first job is to install Docker. I've been as guilty as many with glossing over this step, so here's the massively long and difficult method to install the latest version of Docker on Ubuntu 14. First we make sure ``wget`` is installed:

``` bash
$ which wget
```

And if that returns nothing then we need to install ``wget``:

``` bash
$ sudo apt-get update
$ sudo apt-get install wget
```

And now we can install Docker:

``` bash
wget -qO- https://get.docker.com/ | sh
```

Pop your password in when you're asked and you're done.

## A long time ago on a server far away

Whilst you're still recovering from the trauma of that difficult install, I'm going to cover a bit of background. I've been using Docker for just under a year now, and I've developed a method of working with containers that suits me. I'm not for one second suggesting this is the best way of working, but it works nicely for me.

On each of my Docker hosts, there is a directory at ``/usr/local/docker`` which is where all of my persistent data lives along with a script called ``startup.sh``. All of my Docker related work happens in this script, and it follows this basic pattern:

* Pull the latest version of the images I'm using from the Docker Hub (or my private registry, but that's beyond the scope of this post)
* Delete all of the existing containers
* Start up the required containers

## Why?

The main reason I do this is that starting up a new container is often no slower than re-starting an existing one, and by using the order of pull -> delete -> relaunch, I can be sure that I'm always using the latest version of those containers. I'm also not having to type out **LOOOOONNNNGGG** ``docker run`` commands every time I want to update a container.

The first part of our startup script will be to pull in the images we need. In addition to BSDPy, we need a TFTP server and a basic web server - fortunately Pepjin has you covered with Images for these already in the [macadmins organisation](https://registry.hub.docker.com/repos/macadmins/).

If you're not made it already, we need to make the directory we'll store our permanent bits:

``` bash
$ sudo -i
$ mkdir -p /usr/local/docker/nbi
```

And fire up your favourite editor and put in the first part of our script:

{% codeblock lang:bash /usr/local/docker/startup.sh %}
#!/bin/bash

docker pull macadmins/tftpd
docker pull macadmins/netboot-httpd
docker pull bruienne/bsdpy:1.0
{% endcodeblock %}

Now we just need to make it executable and we can run it:

``` bash
$ chmod 755 /usr/local/docker/startup.sh
$ /usr/local/docker/startup.sh
```

If all goes well Docker will start pulling down the images you need.

## Cleaning up after ourselves

Pop this little snippet after the last ``docker pull`` command - it will stop and remove any existing containers:

``` bash /usr/local/docker/startup.sh
# Other stuff is above here
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

## Linked containers

As previously alluded to, our NetBoot solution will comprise of three components. Add the following to the end of ``/usr/local/docker/startup.sh`` (if your server has more than one ethernet adapter, replace ``eth0`` with the name of the adapter you want to use for NetBoot):

``` bash /usr/local/docker/startup.sh
# Other stuff is above here
chmod -R 777 /usr/local/docker/nbi
IP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
echo $IP

docker run -d \
  -v /usr/local/docker/nbi:/nbi \
  --name web \
  --restart=always \
  -p 0.0.0.0:80:80 \
  macadmins/netboot-httpd

docker run -d \
  -p 0.0.0.0:69:69/udp \
  -v /usr/local/docker/nbi:/nbi \
  --name tftpd \
  --restart=always \
  macadmins/tftpd

docker run -d \
  -p 0.0.0.0:67:67/udp \
  -v /usr/local/docker/nbi:/nbi \
  -e BSDPY_IFACE=eth0 \
  -e BSDPY_NBI_URL=http://$IP \
  -e BSDPY_IP=$IP \
  --name bsdpy \
  --restart=always \
  bruienne/bsdpy:1.0
```

And run your startup script:

``` bash
$ /usr/local/docker/startup.sh
```

You'll see your images being checked for updates, and then your containers will start. you can verify they're running by running:

``` bash
$ docker ps -a
```

## Using the thing

Of course, your NetBoot server isn't going to do anything as you've not uploaded anything for it to serve yet. Get yourself a NetBoot image (if you're using a DeployStudio NBI, delete the symlink to ``NetInstall.dmg`` and rename ``NetInstall.sparseimage`` to ``NetInstall.dmg``).

You're not going to have a GUI to modify the ``NBImageInfo.plist`` so open it up in a text editor. The important parts to change are to make sure that the Mac you're intending to NetBoot is either in ``EnabledSystemIdentifiers`` or not in ``DisabledSystemIdentifiers`` and that ``IsEnabled`` is set to ``<true/>``. If you are going to be serving more than one image, you can set your default image in here.

All done? Time to get that image on your Docker host. From your admin machine (or wherever your NBI currently lives):

``` bash
scp -r /Path/To/MyNetBoot.nbi user@dockerhost:/usr/local/docker/nbi
```

All that remains is to restart the ``bsdpy`` container on your Docker host:

``` bash
$ /usr/local/docker/startup.sh
```

And if you open up the ``bsdpy`` container's logs, you'll see it finding your NBI.

``` bash
$ docker logs bsdpy
```

And if you want to keep the logs open whilst you're testing, you can use ``-f``.

``` bash
$ docker logs -f bsdpy
```

## Conclusion

If you've made it all the way down here, congratulations! You've now managed to move another service off that silly little Mac Mini and onto Linux - and hopefully you now see how easy it is to get things up and running with Docker.
