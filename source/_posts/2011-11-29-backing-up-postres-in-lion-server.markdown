---
date: '2011-11-29 16:10:37'
layout: post
slug: backing-up-postres-in-lion-server
status: publish
title: Backing up Postres in Lion Server
wordpress_id: '30'
comments: true
tags:
- '10.7'
- backup
- lion
- postgres
- server

categories:
- Lion
- Server
- Code

---

Starting with Lion Server, a fair bit of data is now stored in Postgres databases. If you use Time Machine, you'll get this backed up properly for you. If you use a proper backup solution (I prefer CrashPlan), you won't get automated dumps. This script rectifies this, by dumping all of your Postgres data, and keeping 7 days worth.

You can grab the code, along with a pre-built pkg installer from [GitHub](https://github.com/grahamgilbert/Postgres-Backup-for-Lion-Server).



### Configuration


By default, the script puts it's backups in /Backups/Postgres - if you wish to change it, you will need to edit line 3 of /usr/local/pgbackup/pgbackup.sh

{% codeblock lang:bash %}
/usr/local/pgbackup/pgbackup.sh
FINAL_BACKUP_DIR=/path/where/you/want/things/kept
{% endcodeblock %}

The LaunchDaemon will trigger the script every night at 21:00. If you wish to change this, you will need to edit the CalendarStartInterval part of com.grahamgilbert.pgbackup.plist

