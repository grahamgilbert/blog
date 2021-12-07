---
categories:
  - Imagr
  - Flask
  - Docker
  - Python
date: "2016-01-07T09:33:31Z"
title: Dynamic first boot scripts with Imagr and Flask&#58; Part 2
---

If you are just starting with this series, it is highly recommended you start with [Part 1](http://grahamgilbert.com/blog/2016/01/05/dynamic-first-boot-scripts-with-imagr-and-flask/).

Last time we built a basic app that will ask for a username and password to access it. Now we're going to add in some other data that will eventually be sent by Imagr to let our script be dynamically generated. <!--more-->

First off we need to pull out the headers that Imagr will send. We are going to need:

- The Mac's Build
- The Mac's Location

These two options will be stored in a couple of headers. Fortunately, Flask has a built in way of getting the headers from a request. Open up `bootstrap.py` and make our main function look like:

```python linenos:false ~/src/bootstrapapp/bootstrap.py
@app.route('/')
@requires_auth
def index():
build = request.headers.get('X-bootstrap-build')
site = request.headers.get('X-bootstrap-site')

    output = "Build: %s \nSite: %s" % (build, site)
    return output

````

And let's test it. Make sure you've activated the virtualenv we made in the first part and run the debug server:

``` bash
$ source ~/virtualenvs/bootstrapapp/bin/activate
$ cd ~/src/bootstrapapp
$ python bootstrap.py admin secret
````

Aussuming your username and password are `admin` and `secret`, open up your terminal (whilst keeping the debug server running in another window:

```bash
$ curl --user "admin:secret" --header "X-bootstrap-build: build" --header "X-bootstrap-site: site" http://localhost:5000
```

Of course all we're doing is spitting out the header values at the moment - let's add those values to our first boot script. Make your index function look like:

``` python linenos:false ~/src/bootstrapapp/bootstrap.py
@app.route('/')
@requires_auth
def index():
build = request.headers.get('X-bootstrap-build')
site = request.headers.get('X-bootstrap-site')

    script = '''#!/usr/bin/python

import subprocess
import re
import urllib
import os

site='{0}'
build='{1}'
username='{2}'
password='{3}'

def get_hardware_info():
cmd = ['/usr/sbin/system_profiler', 'SPHardwareDataType', '-xml']
proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
stdin=subprocess.PIPE,
stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(output, unused_error) = proc.communicate()
try:
plist = FoundationPlist.readPlistFromString(output) # system_profiler xml is an array
sp_dict = plist[0]
items = sp_dict['_items']
sp_hardware_dict = items[0]
return sp_hardware_dict
except Exception:
return {{}}

hardware_info = get_hardware_info()

serial = hardware_info.get('serial_number', 'UNKNOWN')
serial = re.sub('[^a-za-z0-9]+', '', serial)
serial_lower = serial.lower()
username_and_password = username+':'+password

data={{'serial': serial,'site': site,'build': build}}

cmd = ['/usr/bin/curl', '-u', username_and_password, '--data', urllib.urlencode(data), 'http://localhost:5000/gen_manifest/']
task = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0]

'''.format(site, build, my_username, my_password)
return script

````

Our final job is to make an endpoint that will eventually make the machine's Munki manifest - for now it will just say hello:

``` python linenos:false ~/src/bootstrapapp/bootstrap.py
@app.route('/gen_manifest')
def gen_manifest():
    return 'hello'
````

Now we can test this with Imagr. Open up your Imagr configuration plist and make add in a workflow that looks like:

```xml linenos:false
<dict>
	<key>additional_headers</key>
	<array>
		<string>Authorization: Basic VVNFUk5BTUU6UEFTU1dPUkQ=</string>
		<string>X-enrolment-build: basic</string>
		<string>X-enrolment-site: london</string>
	</array>
	<key>type</key>
	<string>script</string>
	<key>url</key>
	<string>http://yourIPAddress:5000</string>
</dict>
```

You can generate the authorization header, by replacing the appropriate pairts and running this in your terminal:

```bash
python -c 'import base64; print "Authorization: Basic %s" % base64.b64encode("USERNAME:PASSWORD")'
```

And you should see your machine run the script at first boot - it will send it's serial number, and it's build and location for processing by the script that we'll build next time. Remember, if you are netbooting and imaging a VM, this will be fine. If you are doing a real Mac, you will need to replace `localhost` below with the IP address of your Mac that is running `bootstrap.py`.

And here's our code at the end of part 2:

``` python ~/src/bootstrapapp/bootstrap.py
from flask import Flask, request, abort, Response
from functools import wraps
import sys
app = Flask(**name**)
DEBUG = True

try:
my_username = sys.argv[1]
except:
my_username = 'admin'

try:
my_password = sys.argv[2]
except:
my_password = 'secret'

def check_auth(username, password):
"""This function is called to check if a username /
password combination is valid.
"""
return username == my_username and password == my_password

def authenticate():
"""Sends a 401 response that enables basic auth"""
return Response(
'Could not verify your access level for that URL.\n'
'You have to login with proper credentials', 401,
{'WWW-Authenticate': 'Basic realm="Login Required"'})

def requires_auth(f):
@wraps(f)
def decorated(*args, \*\*kwargs):
auth = request.authorization
if not auth or not check_auth(auth.username, auth.password):
return authenticate()
return f(*args, \*\*kwargs)
return decorated

@app.route('/gen_manifest')
def gen_manifest():
return 'hello'

@app.route('/')
@requires_auth
def index():
build = request.headers.get('X-bootstrap-build')
site = request.headers.get('X-bootstrap-site')

    script = '''#!/usr/bin/python

import subprocess
import re
import urllib
import os

site='{0}'
build='{1}'
username='{2}'
password='{3}'

def get_hardware_info():
cmd = ['/usr/sbin/system_profiler', 'SPHardwareDataType', '-xml']
proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
stdin=subprocess.PIPE,
stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(output, unused_error) = proc.communicate()
try:
plist = FoundationPlist.readPlistFromString(output) # system_profiler xml is an array
sp_dict = plist[0]
items = sp_dict['_items']
sp_hardware_dict = items[0]
return sp_hardware_dict
except Exception:
return {{}}

hardware_info = get_hardware_info()

serial = hardware_info.get('serial_number', 'UNKNOWN')
serial = re.sub('[^a-za-z0-9]+', '', serial)
serial_lower = serial.lower()
username_and_password = username+':'+password

data = {{
'serial': serial,
'site': site,
'build': build
}}

cmd = ['/usr/bin/curl', '-u', username_and_password, '--data', urllib.urlencode(data), 'http://localhost:5000/gen_manifest/']
task = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0]

'''.format(site, build, my_username, my_password)
return script

if **name** == '**main**':
app.run(host='0.0.0.0', debug=DEBUG)

```

```
