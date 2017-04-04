---
title: Using Caddy to HTTPS all the things
date: 2017-04-04T07:22:39-07:00
layout: post
categories:
 - Docker
 - Linux
 - LetsEncrypt
---

[Caddy](https://caddyserver.com/) is a lightweight web server that amongst it's features, has integration with [LetsEncrypt](https://letsencrypt.org) to automatically request certificates. This means that you now have absolutely no excuse anymore to run your apps over plain old HTTP anymore. Let me be clearer. If you are running web services over HTTP, regardless of whether it touches the internet or not, __you are doing it wrong__.  <!-- more -->

## The setup

I have set up an [AWS EC2](https://aws.amazon.com/ec2) instance to run this on. You can use another provider if you want, but you can use the [free tier of AWS](https://aws.amazon.com/free) for a year. I am running the following:

* A t2.micro Ubuntu 16.04 instance with 20 GB of storage attached (probably excessive for this demo setup).
* Assigned an Elastic IP to the instance (so it has an external IP)
* Created an A record in DNS that points to the elastic IP (needed for LetsEncrypt)
* Allowed SSH, HTTP and HTTPS into the instance via the security group

The setup of the above is out of the scope of this post, but it should be easily google-able.

### Docker

We are going to run all of this in Docker containers. SSH into the server and:

``` bash
$ sudo apt-get -y install apt-transport-https ca-certificates curl
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
$ sudo apt-get update
$ sudo apt-get -y install docker-ce
```

## Caddy

Let's get Caddy up and running. There's a decent image already that makes it pretty easy to stand up a web server. First off we're just going to pull the image and serve the default site over HTTP.

``` bash
$ sudo docker run -d --name caddy \
    -p 80:2015 \
    abiosoft/caddy
```

And if you hit you server's hostname (e.g. example.yourdomain.com), you will now see the default page for your Caddy server.

{% img center /images/posts/2017-04-04/01_default_caddy_http.png %}

That's all well and good, but using the default configuration isn't very useful. Put the following into a file called `Caddyfile`. Once again, replace `example.yourdomain.com` with the actual hostname that points to your server.

```
example.yourdomain.com
```

And let's kill our old container and start up a new one:

```
$ sudo docker rm -f caddy
$ sudo docker run -d --name caddy \
    -p 80:80 \
    -v $(pwd)/Caddyfile:/etc/Caddyfile \
    abiosoft/caddy
```

So we have what we had before. How do we configure Caddy to serve HTTPS? We don't need to do anything, we just need to hook up port `443` in our container to the outside world.

```
$ sudo docker rm -f caddy
$ sudo docker run -d --name caddy \
    -p 80:80 \
    -p 443:443 \
    -v $(pwd)/Caddyfile:/etc/Caddyfile \
    abiosoft/caddy
```

And then reload your page in your browser.

{% img center /images/posts/2017-04-04/02_default_caddy_https.png %}

__OMG IT'S HTTPS WITHOUT DOING ANYTHING!__

## Sal

So let's make this do something useful. We are going to make use of Caddy's ability to be a reverse proxy so that it can sit in front of our Sal container and provide easy HTTPS. First off we're going to stand up a normal Sal install - notice we do not expose any of Sal's ports to the outside.

``` bash
$ sudo docker rm -f caddy
$ sudo docker run -d --name db \
    -v /home/ubuntu/db:/var/lib/postgresql/data \
    --restart always \
    -e DB_NAME=sal \
    -e DB_USER=admin \
    -e DB_PASS=password \
    grahamgilbert/postgres:9.6.2
```

Now your database has started (you can `sudo docker logs db` to make sure), it's time for our Sal container.

``` bash
$ sudo docker run -d --name sal \
    --restart always \
    -e DB_NAME=sal \
    -e DB_USER=admin \
    -e DB_PASS=password \
    -e ADMIN_PASS=password \
    --link db:db \
    macadmins/sal
```

As soon as `sudo docker logs sal` says that gunicorn is running, we're ready to expose it to the internet. We are going to make use of a feature in Docker where we automagically get access to the other containers it is linked to (in this case, we are going to hit http://sal:8000). Open up your `Caddyfile` and make it look like the following:

```
example.yourdomain.com {
    proxy / http://sal:8000
}
```

And finally we can start up our proxy container:

``` bash
$ sudo docker run -d --name caddy \
    -p 80:80 \
    -p 443:443 \
    --link sal:sal \
    -v $(pwd)/Caddyfile:/etc/Caddyfile \
    abiosoft/caddy
```

And like magic...

{% img center /images/posts/2017-04-04/03_sal_https.png %}

Doing this will re-request new certificates from LetsEncrypt every time the container is removed and recreated. If you do this often enough, you will hit their rate limit, so let's make sure we keep the certificates by linking the right directory in our container to the host machine.

``` bash
$ sudo docker run -d --name caddy \
    -p 80:80 \
    -p 443:443 \
    --link sal:sal \
    -v $(pwd)/Caddyfile:/etc/Caddyfile \
    -v $(pwd)/caddy:/root/.caddy \
    abiosoft/caddy
```

## Wrap up

So that is how you can run any app behind HTTPS for free. No go and get everything encrypted. No excuses. I don't want to see any more installations of [Sal](https://github,com/salopensource/sal) or [Crypt](https://github.com/grahamgilbert/Crypt-Server) running unencrypted. Please - or I may cry.
