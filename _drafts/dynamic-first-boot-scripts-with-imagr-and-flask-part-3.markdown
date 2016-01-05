---
title: Dynamic first boot scripts with Imagr and Flask&#58; Part 3
---
If you are just starting with this series, it is highly recommended you start with Part 1. 

Last time around we got our app returning something useful to Imagr. This time around we'll make our second endpoint - the one that will create the machine's individual Munki manifest on the server.

Our fictional setup is making use of the default manifests Munki looks for - eventually it will request the machine's serial number if no client identifier is set. Our manifest will contain three other included manifests:

* One for the site where the machine is located.
* One for the machine's build.
* A general one for all machines (the site default).<!-- more -->

The first job is to import the ``plistlib`` module. Python has built in support for handling plists, but we need to tell it about them. Put the following line in ``bootstrap.py`` after your other imports at the top:

``` python linenos:false ~/src/bootstrapapp/boostrap.py
import plistlib
import os
```

In our final Docker image, we'll be expecting to mount our production Munki repo into it, but for now we'll assume it's in the same directory as `bootstrap.py`. The following code will:

* Check to see if the machine already has a manifest.
* If it doesn't, it will be added to the ``production`` catalog. If it does, it will keep it's current catalog.
* It will add the included manifests mentioned above to the manifest.

Now for the code that will actually make our Munki manifest. Replace the section that looks like:

``` python linenos:false ~/src/boostrapapp/bootstrap.py
@app.route('/gen_manifest')
def gen_manifest():
    return 'hello'
```

with:

``` python linenos:false ~/src/boostrapapp/bootstrap.py
@app.route('/gen_manifest', methods = ['GET', 'POST'])
@requires_auth
def gen_manifest():
    build = request.form.get('build', None)
    site = request.form.get('site', None)
    serial = request.form.get('serial', None)
    # If we're re-imaging, these are required
    if build == None or site == None or serial == None:
        abort(403)

    # Currently we're assuming it's in the same directory as this script
    munki_repo = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                            'munki_repo')
    manifest_file = os.path.join(munki_repo, 'manifests', serial)
    # if the manifest doesn't already exist set the catalog
    if not os.path.isfile(manifest_file):
        manifest = {}
        manifest['catalogs'] = ['production']
    else:
        manifest = plistlib.readPlist(manifest_file)
    manifest['included_manifests'] = ['site_default']
    if site:
        site_manifest = 'included_manifests/sites/%s' % site
        manifest['included_manifests'].append(site_manifest)
    if build:
        build_manifest = 'included_manifests/builds/%s' % build
        manifest['included_manifests'].append(build_manifest)
    plistlib.writePlist(manifest, manifest_file)

    return 'Manifest saved'
```

Let's make sure there aren't any errors. Make sure you've activated the virtualenv we made in the first part and run the debug server:

``` bash
$ source ~/virtualenvs/bootstrapapp/bin/activate
$ cd ~/src/bootstrapapp
$ python bootstrap.py admin secret
``` 

Make sure there are ``munki_repo`` and ``manifests`` directories in ``~/src/bootstrapapp`` (so you have ``~/src/boostrapapp/munki_repo/manifests``) and try curling your second script:

``` bash
$ curl --user "admin:secret" --data 'serial=abc123&site=london&build=somebuild' http://localhost:5000/gen_manifest
```

All being well, you will see your manifest being made in the right place.

And for the sake of completeness, here's ``bootstrap.py`` after the end of part 3.

``` python ~/src/boostrapapp/bootstrap.py
from flask import Flask, request, abort, Response
from functools import wraps
import sys
import plistlib
import os
app = Flask(__name__)
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
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/gen_manifest', methods = ['GET', 'POST'])
@requires_auth
def gen_manifest():
    build = request.form.get('build', None)
    site = request.form.get('site', None)
    serial = request.form.get('serial', None)
    # If we're re-imaging, these are required
    if build == None or site == None or serial == None:
        abort(403)

    # Currently we're assuming it's in the same directory as this script
    munki_repo = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                            'munki_repo')
    manifest_file = os.path.join(munki_repo, 'manifests', serial)
    # if the manifest doesn't already exist set the catalog
    if not os.path.isfile(manifest_file):
        manifest = {}
        manifest['catalogs'] = ['production']
    else:
        manifest = plistlib.readPlist(manifest_file)
    manifest['included_manifests'] = ['site_default']
    if site:
        site_manifest = 'included_manifests/sites/%s' % site
        manifest['included_manifests'].append(site_manifest)
    if build:
        build_manifest = 'included_manifests/builds/%s' % build
        manifest['included_manifests'].append(build_manifest)
    plistlib.writePlist(manifest, manifest_file)

    return 'Manifest saved'

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

cmd = ['/usr/bin/curl', '-u', username_and_password, '--data', urllib.urlencode(data), 'http://localhost:5000/gen_manifest/']
task = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0]

'''.format(site, build, my_username, my_password)
    return script

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=DEBUG)
```