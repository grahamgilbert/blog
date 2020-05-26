---
categories:
- Docker
comments: true
date: "2015-08-26T12:18:19Z"
title: Using a proxy container with Docker for virtualhosts
---

I've been asked a few times over the last few weeks about how you can have multiple services (for example, Munki and Sal) running on the same port on the same server - how we used to do Virtual Hosting when we ran our apps on the host OS. My usual four word answer has been 'use a proxy container'. How you actually do that has been undocumented - this post hopes to recitfy that.<!--more-->

Let's consider a usual setup that has Sal and Munki running on the same box. We have two hostnames that both resolve to our Docker server - ``sal.example.com`` and ``munki.example.com``, and we have our containers running in a manner similar to the below:

![Container layout](/images/posts/2015-08-26/proxycontainerlayout.png)

Each of our containers is linked to it's parent:

``` bash
# Munki server
docker run -d \
-v /usr/local/docker/munki:/munki_repo \
--restart="always" \
--name="munki" \
macadmins/munki

# Postgres container for Sal
docker run -d --name="postgres-sal" \
-v /usr/local/docker/sal/db:/var/lib/postgresql/data \
-e DB_NAME=sal \
-e DB_USER=admin \
-e DB_PASS=password \
--restart="always" \
grahamgilbert/postgres

# Sal Container
docker run -d \
-e ADMIN_PASS=pass \
-e DB_NAME=sal \
-e DB_USER=admin \
-e DB_PASS=password \
--name="sal" \
--link postgres-sal:db \
--restart="always" \
macadmins/sal

# Proxy
docker run -d --name="proxy" \
--link sal:sal \
--link munki:munki \
-v /usr/local/docker/proxy/sites-templates:/etc/nginx/sites-templates \
-v /usr/local/docker/proxy/keys:/etc/ssl/keys \
-p 443:443 \
-p 80:80 \
--restart="always" \
grahamgilbert/proxy
```

So how does the ``proxy`` container know about the other containers? When you link a Docker container to another, a few environment variables are made available to you - there are two we're interested in:

* ``CONTAINERNAME_PORT_EXPOSEDPORTNUMBER_TCP_ADDR``
* ``CONTAINERNAME_PORT_EXPOSEDPORTNUMBER_TCP_PORT``

So in the case of the Sal container, it would be ``SAL_PORT_8000_TCP_ADDR`` and ``SAL_PORT_8000_TCP_PORT``. The [``grahamgilbert/proxy``](https://hub.docker.com/r/grahamgilbert/proxy/) image will simply run over any file named ``*.tmpl`` in ``/etc/nginx/sites-templates`` and replace the palceholders with the value that's in the environent variable - here's my nginx configuration file template for Sal:

{% codeblock nginx /etc/nginx/sites-templates/sal.example.com.tmpl %}
server {
       listen         80;
       server_name    sal.example.com;
       rewrite        ^ https://$server_name$request_uri? permanent;
}

server {
        listen              443 ssl;
        server_name         sal.example.com;
        ssl_certificate     /etc/ssl/keys/ssl-unified.crt;
        ssl_certificate_key /etc/ssl/keys/sal.key;

        location / {
            proxy_pass http://${SAL_PORT_8000_TCP_ADDR}:${SAL_PORT_8000_TCP_PORT}; # set to your own port
            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     
            client_max_body_size 10m;
            client_body_buffer_size 128k;
     
            proxy_connect_timeout 90;
            proxy_send_timeout 90;
            proxy_read_timeout 90;
            proxy_buffer_size 4k;
            proxy_buffers 4 32k;
            proxy_busy_buffers_size 64k;
            proxy_temp_file_write_size 64k;
        }
    }
{% endcodeblock %}
    
Using this technique, you can have as many containers as you like all serving content on the same port number - just change line 14 above to reflect the exposed ports and names of your Docker containers.