---
title: Dynamic first boot scripts with Imagr and Flask&#58; Part 4
---
If you are just starting with this series, it is highly recommended you start with Part 1. 

The last part of this series is making it work in a Docker container. This is **not** a Docker tutorial - please head over to Docker's [getting started](https://docs.docker.com/mac/) pages to get yourself set up with the Docker Toolbox.

All done? Let's crack on with first creating our Dockerfile. <!-- more -->

In the same ``~/src/boostrapapp`` directory as your main script, create a new file called ``Dockerfile`` with the following contents:

``` dockerfile ~/src/boostrapapp/Dockerfile
FROM python:2.7-slim

COPY requirements.txt /requirements.txt
COPY gunicorn_config.py /gunicorn_config.py
COPY bootstrap.py /bootstrap.py
RUN pip install -r /requirements.txt && \
    rm /requirements.txt && \
    pip install gunicorn futures
CMD gunicorn -c gunicorn_config.py bootstrap:app
VOLUME ["/munki_repo"]
```

In the Dockerfile we copied a couple of files. The first is the requirements file - this will install the bits into python we need to run our app. Fortunately, this is incredibly easy to generate:

``` bash
$ source ~/virtualenvs/bootstrapapp/bin/activate
$ cd ~/src/bootstrapapp
$ pip freeze > requirements.txt
```

And now for ``gunicorn_config.py``. Up until now we have been using Flask's built in web server. This is fine for development, but in production it is better to use a more robust server. You would normally put an app running with Gunicorn behind a proxy server (you could use my [Proxy image](http://grahamgilbert.com/blog/2015/08/26/using-a-proxy-container-with-docker-for-virtualhosts/)), but this time we won't for the sake of simplicity.

``` python
import multiprocessing
from os import getenv
bind = '0.0.0.0:5000'
workers = multiprocessing.cpu_count() * 2 + 1
timeout = 600
threads = multiprocessing.cpu_count() * 2
max_requests = 600
max_requests_jitter = 50
errorlog = '-'
accesslog = '-'
loglevel = 'warning'
# Read the DEBUG setting from env var
try:
    if getenv('BOOTSTRAP_DEBUG').lower() == 'true':
        loglevel = 'debug'
except:
    pass
```

Our last step before building the image is to replace a few parts that we've hardcoded into ``bootstrap.py`` with environment variables so they can be customised when the Docker image is run.

First off we have our username and password for HTTP authentication. Change:

``` python linenos:false ~/src/boostrapapp/bootstrap.py
try:
    my_username = sys.argv[1]
except:
    my_username = 'admin'

try:
    my_password = sys.argv[2]
except:
    my_password = 'secret'
```

To look like:

``` python linenos:false ~/src/boostrapapp/bootstrap.py
try:
    my_username = os.getenv('BOOTSTRAP_USERNAME', 'admin')
except:
    my_username = 'admin'

try:
    my_password = os.getenv('BOOTSTRAP_PASSWORD', 'secret')
except:
    my_password = 'secret'
```

Running our app in debug mode is useful during development, but can pose a security risk in production - let's be able to turn that on and off. Replace ``DEBUG = True`` at the top of ``boostrap.py`` with:

``` python linenos:false ~/src/bootstrapapp/bootstrap.py
try:
    if getenv('BOOTSTRAP_DEBUG').lower() == 'true':
        DEBUG = True
    else:
        DEBUG = False
except:
    DEBUG = False
```

One last part is to be able to set our URL that the app is served on - we return this in the script that is sent to our clients, so we need to tell the container about it. Replace your ``def index`` section with:

``` python linenos:false ~/src/bootstrapapp/bootstrap.py
@app.route('/')
@requires_auth
def index():
    build = request.headers.get('X-bootstrap-build')
    site = request.headers.get('X-bootstrap-site')
    url = os.getenv('BOOTSTRAP_URL', 'http://localhost:5000')
    script = '''#!/usr/bin/python
import subprocess
import re
import urllib
import os

site='{0}'
build='{1}'
username='{2}'
password='{3}'
url='{4}'

def get_hardware_info():
    cmd = ['/usr/sbin/system_profiler', 'SPHardwareDataType', '-xml']
    proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, unused_error) = proc.communicate()
    try:
        plist = FoundationPlist.readPlistFromString(output)
        # system_profiler xml is an array
        sp_dict = plist[0]
        items = sp_dict['_items']
        sp_hardware_dict = items[0]
        return sp_hardware_dict
    except Exception:
        return {{}}

hardware_info = get_hardware_info()

serial = hardware_info.get('serial_number', 'UNKNOWN')
serial = re.sub('[^A-Za-z0-9]+', '', serial)
serial_lower = serial.lower()
username_and_password = username+':'+password
data = {{
'serial': serial,
'site': site,
'build': build
}}

cmd = ['/usr/bin/curl', '-u', username_and_password, '--data', urllib.urlencode(data), url+'/gen_manifest/']
task = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0]

'''.format(site, build, my_username, my_password, url)
    return script
```

## Prepare the build

Now we're ready to build our Docker image. Make sure your  Docker Machine VM is running and that you've run all the commands the Docker guide told you to and:

``` bash
docker build -t bootstrapapp .
```

You'll see the base image being downloaded (if you don't already have it) and then each step of your Dockerfile being run. Now we've got an image built, let's run it. Assuming your VM's IP address is ``172.16.155.136`` (you can get yours by running ``docker-machine ip YOURVMNAME``):

``` bash linenos:false
$ docker run -d --name=bootstrap \
    -e BOOTSTRAP_URL='http://172.16.155.136:5000' \
    -e BOOTSTRAP_USERNAME=myadmin \
    -e BOOTSTRAP_PASSWORD=mypassword \
    -v /Users/grahamgilbert/src/bootstrapapp/munki_repo:/munki_repo \
    -p 5000:5000 \
    bootstrapapp
```

Obviously replace ``/Users/grahamgilbert`` with your own home directory.

## Will it blend?

Let's try pulling the script down:

``` bash
curl --user "myadmin:mypassword" --header "X-bootstrap-build: build" --header "X-bootstrap-site: site" http://172.16.155.136:5000
```


Let's test manifest creation:

``` bash
$ curl --user "myadmin:mypassword" --data 'serial=xyz789&site=london&build=somebuild' http://172.16.155.136:5000/gen_manifest
```

You should see your manifest being created on your Mac's filesystem.

And you can also see what your container is doing:

``` bash
docker logs bootstrap
```

## What's next?

You could now [push this image to the Docker Hub](https://docs.docker.com/engine/userguide/dockerrepos/), or you could build it on your server. If you want to see the completed project, I've posted it on GitHub, and I've set up an automated build on the Docker Hub if you want to use it and be lazy ;)

## Fin

Congratulations - you've build a web app using the Flask framework, dynamically served scripts to Imagr, made your manifests for Munki on the fly and wrapped it all up into a Docker image.