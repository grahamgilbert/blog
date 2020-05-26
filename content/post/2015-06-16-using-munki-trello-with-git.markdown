---
categories:
- Munki
- Automation
comments: true
date: "2015-06-16T11:21:58Z"
title: Using munki-trello with Git
---

So you're managing your catalogs with [munki-trello](http://grahamgilbert.com/blog/2015/02/11/managing-munki-catalogs-with-trello/), but you also want to use git and [git-fat](https://www.afp548.com/2014/12/01/git-fat-intro-part-two-setup-and-migration/) to track the changes - what do you do?

If you were using the script that I posted previously, your changes would be mangled when you pull in changes  - it turned out the solution was simple. I'm going to assume your Munki server has commit access to your Munki git repository. We're pulling down the latest version of the git repo before performing any work, and then we're git adding just the ``catalogs`` and ``pkgsinfo`` directories - the only directories munki-trello will modify. And if there aren't any changes, git won't commit anything, so we can just run ``git commit`` and ``git push`` without worrying about it.

If we schedule the below script to happen regularly (via cron), we also get our git changes deployed automagically.

``` bash /usr/local/bin/munki-trello.sh
#!/bin/bash

# Cron doesn't have $PATH set as we do, need to find git fat
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH

# Change this to wherever your Munki repository is on disk
cd /usr/local/docker/munki

# Pull down changes
git pull

# and the 'fat' files
git fat pull

docker pull pebbleit/munki-trello

docker run --rm -v /usr/local/docker/munki:/munki_repo \
-e DOCKER_TRELLO_KEY=mytrellokey \
-e DOCKER_TRELLO_TOKEN=mytrellotoken \
-e DOCKER_TRELLO_BOARDID=myboardid \
pebbleit/munki-trello


git add catalogs
git add manifests
git add pkgsinfo

# Change the following line if you want to change the git commit message
now="$(date)"
git commit -m "Munki Trello commit $now"

git push
```
