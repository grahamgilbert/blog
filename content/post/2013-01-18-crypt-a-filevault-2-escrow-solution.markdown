---
categories:
- FIleVault
- OS X
- Code
comments: true
date: "2013-01-18T00:00:00Z"
title: 'Crypt: A FileVault 2 escrow solution'
---
Although it's been blogged about over at [afp548](http://afp548.com/2013/01/02/crypt-a-client-and-web-app-for-filevault-2-encryption-and-escrow/) and [Rich Trouton's blog](http://derflounder.wordpress.com/2012/12/31/first-look-at-crypt/), I'd like to introduce you all to [Crypt](https://github.com/grahamgilbert/Crypt). 

{{< figure class="center" src="/images/posts/2013-01-18/Crypt-Screenshot.png" >}}

Crypt is a solution for enabling FileVault 2 on Macs running either 10.7 or 10.8 and securely storing those keys, using no outside infrastructure like other solutions do (Cauliflower Vest's requirement of Google App Engine). It's only requirement is a web server that can run a Django app (which is pretty much anything - the example setup uses Apache on Ubuntu 12, but you can use anything you want).

Crypt is made up of two parts: A [web app](https://github.com/grahamgilbert/Crypt-Server), which stores the recovery keys and a [client app](https://github.com/grahamgilbert/Crypt) for enabling FileVault 2 on a Mac which then sends the recovery key to the server. The server has two user levels, so access to keys can be restricted, and all key access is logged for auditing. 

We've been using it at [pebble.it](http://pebbleit.com) for a few weeks now and haven't found any issues during use, but please be aware that this is what I'd call "beta" software. You might be happy using beta software in production, but that's up to you! I'd welcome all feedback, both good and bad. Planned features include AD authentication and emails to admins when new requests come in. Please file bugs and feature requests over at [GitHub](https://github.com/grahamgilbert/Crypt) so I can keep track of them all.