---
layout: post
title: "Creating Business Units and Groups in Sal using a CSV"
date: 2014-12-08 08:52:21 +0100
comments: true
categories: 
- Python
- Sal
---
Obviously I'm a little biased, but I love Sal. But, it can be a little tedious to get everything set up the first time if you have hundreds of Business Units and Machine Groups. I've quietly ignored the problem for a while, but then I saw this tweet pop up in my feed:

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/hunty1er">@hunty1er</a> Pretty sure you could automate BU/MG creation through the DB backend. What say you <a href="https://twitter.com/grahamgilbert">@grahamgilbert</a> ?</p>&mdash; Pepijn Bruienne (@bruienne) <a href="https://twitter.com/bruienne/status/541811445512830976">December 8, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

What say I Mr Bruienne? Like the [man from Del Monte](https://www.youtube.com/watch?v=mjB9Chw_6FE), I say YES!

## The plan

We're going to use a few of the parts that make Django and Docker awesome. We will:

* Make a custom management command that will read in a CSV
* The command will make the Business Units and Groups if they don't exist
* We're than going to run it in a temporary Docker container when we're ready to do the actual import. This is one of the strengths of Docker - we can spin up a linked container that will operate on the main database, but won't interfere with your container serving the app.
<!-- more -->
## Let's do this thing

Custom management commands are where you can add your own command to be available under ``./manage.py my_command`` - and they're pretty easy to make. I've made a quick and dirty one (that works, but there will probbaly be edge cases where it doesn't).

I'm assuming you're running Sal in the recommended way using Docker. If you're not, you can drop the management repo in ``/path/to/sal/server/management``.

To use it, first you're going to need to clone the repository somewhere on your disk. I'm going to assume you're working out of ``/usr/local/docker``. There's an example CSV included in the repo.

``` bash
$ cd /usr/local/docker
$ git clone https://github.com/grahamgilbert/sal-import-example
```

Next we're going to run a temporary Docker container on the same host that our existing Sal container is running on. This container will run the import, and when it's done it will delete itself (``--rm``). We've linked in the import data and the additional management command. So we can see the output, we're running it in the foreground as well (``-i``). Finally, we run the custom management command and point it to the CSV.

``` bash
$ docker run -t -i -v /vagrant/sal/settings.py:/home/docker/sal/sal/settings.py \
  -e ADMIN_PASS=pass \
  -e DB_NAME=sal \
  -e DB_USER=admin \
  -e DB_PASS=password \
  --link postgres-sal:db \
  --rm \
  -v /vagrant/sal/management:/home/docker/sal/server/management \
  -v /vagrant/sal/data.csv:/data.csv \
  macadmins/sal \
  python /home/docker/sal/manage.py loadcsv /data.csv
```
  
And you'll get the output reporting that your CSV did it's job:
 
``` bash
Omni Mega Corp didn't exist and has been created.
Machine Group 1 didn't exist and has been created.
Omni Mega Corp already exists.
Machine Group 2 didn't exist and has been created.
Honest Bob's Burgers didn't exist and has been created.
Machine Group 3 didn't exist and has been created.
```

There it is - a simple management command to automate tasks with Sal and running it in a temporary Docker container. You can use the temporary container technique for many tasks - performing a ``repo_sync`` on a [Reposado container](https://registry.hub.docker.com/u/macadmins/reposado/) is a good example.