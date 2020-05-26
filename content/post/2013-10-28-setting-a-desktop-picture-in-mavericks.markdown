---
categories:
- OS X
- Mavericks
- Python
comments: true
date: "2013-10-28T00:00:00Z"
title: Setting a desktop picture in Mavericks
---
Sometimes we are asked by clients to set a default desktop picture for new users - sometimes we are deleting home directories on logout, so need to warn the users, other times the client just wants their corporate wallpaper to be the default.

If you are lazy and don't want to read this post then the script that changes the desktop picture [is on GitHub](https://github.com/grahamgilbert/macscripts/tree/master/set_desktops).

Whatever, here's what we used to do:

``` bash
/usr/bin/defaults write com.apple.desktop Background '{default = {ImageFilePath = "/Library/Desktop Pictures/Black & White/Lightning.jpg"; };}'
/usr/bin/killall Dock
```

Nothing earth shattering there if you've managed Macs for any length of time.

But then 10.9 changed things - this stopped working. 

I ran fs_usage to see what was happening whilst I changed the desktop picture on my machine:

``` bash
$ sudo fs_usage -w | grep desktop
```

Obviously there was a metic buttload of information, but this line caught my eye.

```
15:25:06.884820    WrData[A]       D=0x0b2d1d90  B=0x1000   /dev/disk1  /Users/grahamgilbert/Library/Application Support/Dock/desktoppicture.db
```

Bingo! I opened up the database in the [SQLite Manager Firefox extension](https://addons.mozilla.org/en-US/firefox/addon/sqlite-manager/) (the only thing I use Firefox for these days) and had a peek. And then I got half a brain and googled the path of the desktoppicture.db file and found that there was a [gist from Greg Neagle](https://gist.github.com/gregneagle/6225747). Perfect!

Of course, he'd already improved upon this script and written a proof of concept to [set a random desktop picture using PyObjC](https://gist.github.com/gregneagle/6957826). This got me 90% of the way there, so this is my modified version of his script. The full code and usage instructions are [over on GitHub](https://github.com/grahamgilbert/macscripts/tree/master/set_desktops).