---
categories:
- Lion
- Server
- Code
comments: true
date: "2011-11-22T21:17:27Z"
slug: kerio-connect-vs-web-services-in-lion-server
status: publish
tags:
- "10.7"
- kerio connect
- lion
- server
- web
- webappctl
title: Kerio Connect vs Web Services in Lion Server
wordpress_id: "13"
---

### The problem


Lion Server takes over every ethernet interface when you enable any web services (Web, Wiki, Profile Manager, basically anything!). This leaves us with two options: putting Kerio on a non-standard port and getting the users to type that in every time, or completely disabling apache and not using any of the good stuff that came with Lion Server. Or, we could work out a way to redirect users to the right port number when they hit mail.example.com

Enter Reverse Proxy. This takes the request for the mail.example.com virtual host, and redirects it to our custom HTTPS port (8843).



### How to do it


The files you need are on my [GitHub](https://github.com/grahamgilbert/Lion_Kerio). Replace mail.example.com with the FQDN of your mail server.

1.	Set up your lion server first. Configure SSL certificates, OD and web services the way you like it.
2.	Export your private key for the signed SSL certificate from the keychain.
3.	Install Kerio Connect. Import the private key and your signed certificate.
4.	Set Kerio to use only port 8800 for HTTP and 8843 for HTTP and HTTPS, respectively.
5.	Set Kerio to bind it's services to All Interfaces rather than a specific IP address. (I've found that services won't start when it's listening on all IPs, but will when it can listen to all - don't ask me why!)
6.	In Server.app, configure mail.example.com in Web. Set it to use port 443, set the root folder to whatever you want (it won't be used).
7.	In Hardware, set the virtual host you just created to use the right ssl cert.
8.	In terminal: ```cd /path/to/the/files/you/downloaded```
9.	In terminal again: ```sudo cp httpd_kerio.conf /etc/apache2/httpd_kerio.conf```
10.	And again: ```sudo cp webapps/com.grahamglbert.kerio.plist /etc/apache2/webapps/com.grahamglbert.kerio.plist```
11.	One last time: ```sudo webappctl start com.grahamgilbert.kerio mail.example.com```

### What's happening

By default, when you specify a vhost to use ssl in lion server, any requests to port 80 are redirected to 443. Once it's wrapped in ssl, it's redirected transparently to 8843, so the user is sent to the webmail login.

The plist file is the core of the webapp mechanism that was introduced with lion server. Within that all we're doing is importing the httpd_kerio.conf file (which just has a standard apache reverse proxy directive) and telling the app to always use ssl. The webappctl command is simply telling the webapp mechanism to load our plist and start it on the mail.example.com vhost. 

### Known Issues

#### Entourage

Entourage accounts will need to be reconfigured with the Kerio setup tool. They don't seem to like communicating with the server over port 443 when the reverse proxy is running - they will have issues sending email.

#### Kerio Services

The services in Kerio Admin will need to be set to run on All Interfaces rather than a set IP address, as they won't start on a specific address (it is unknown whether this is because of the reverse proxy / webapp process or if this is a general Lion issue). If the service has stopped, the webapp will need to be restarted:

	sudo webappctl stop com.grahamgilbert.kerio mail.example.com
	sudo webappctl start com.grahamgilbert.kerio mail.example.com
