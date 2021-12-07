---
categories:
  - Imagr
  - Flask
  - Docker
  - Python
date: "2016-01-05T10:22:31Z"
modified: null
title: Dynamic first boot scripts with Imagr and Flask
---

Some may wonder why you would go to the trouble of dynamically generating first boot scripts. I mean, how many can you need?

Let's say you have ten sites, each with five builds - that fifty first boot scripts to maintain already. It's entirely possible that they're all the same, so you could use [Imagr's ability to use a script from a central URL](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#scripts). But you also may need to make slight tweaks depending on what type of machine it is and where it is located.

Over the next few posts, we are going to build an app using the [Flask](http://flask.pocoo.org) framework that will:

- Read in headers sent by [Imagr](https://github.com/grahamgilbert/) to return a dynamically generated first boot script
- Create a Munki manifest for the Mac
- Wrap up the application into a Docker image so it can be easily deployed<!--more-->

## Let's get started

The first thing we are going to do is to set up a virtual env. We are using Python to create our app and putting our dependencies in a virtual env means that we are not potentially messing up our system.

```bash
$ sudo easy_install virtualenv
$ mkdir ~/virtualenvs
$ cd ~/virtualenvs
$ virtualenv bootstrapapp
```

Now we can start building our app. Assuming you are going to keep your app in `~/src/bootstrapapp`:

```bash
$ mkdir -p ~/src/bootstrapapp
$ cd ~/src/bootstrapapp
```

And now we need to switch to using the Python in the virtualenv rather than the system one

```bash
$ source ~/virtualenvs/bootstrapapp/bin/activate
```

Now we can install our first dependency - Flask itself. Pip is the package manager that is installed in every new virtualenv you create. It's pretty easy to use:

```bash
$ pip install flask
```

Now Flask is installed, we can start on the web app. Crack open your favourite editor (not textedit! Python is picky about spaces) and create the following file:

``` python ~/src/bootstrapapp/bootstrap.py
from flask import Flask
app = Flask(**name**)

@app.route('/')
def index():
return 'Hello World!'

if **name** == '**main**':
app.run()

````

And now we can run it:

``` bash
python bootstrap.py
````

Now head over to `http://localhost:5000` in a browser and...

Yeah! Your first flask app! But we will be wanting to restrict who can access this. We are going to implement basic HTTP authentication to give our app some protection. Make your `bootstrap.py` look like the below:

``` python ~/src/bootstrapapp/bootstrap.py
from flask import Flask, request, abort, Response
from functools import wraps
import sys
app = Flask(**name**)
DEBUG = True

def check_auth(username, password):
"""This function is called to check if a username /
password combination is valid.
"""
return username == 'admin' and password == 'secret'

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

@app.route('/')
@requires_auth
def index():
return 'Hello World!'

if **name** == '**main**':
app.run(host='0.0.0.0', debug=DEBUG)

````

We've made a couple of changes here. We've enabled debug mode - this throws up more useful errors in the unlikely event I make a mistake (ahem). When we move into production, we will want to disable this for security reasons.

We have also added a few functions that will let us add basic authentication. If you would like to change the username from ``admin`` and password from ``secret``, change the values at the end of ``check_auth``).

When we run this with Docker, we'll use environment variables to pass in the username and password, but for now we'll use command line options. Add this in below ``DEBUG=True`` and above ``def check_auth(username, password):``

``` python linenos:false
try:
    my_username = sys.argv[1]
except:
    my_username = 'admin'

try:
    my_password = sys.argv[2]
except:
    my_password = 'secret'
````

And change `def check_auth` to look like:

```python linenos:false
def check_auth(username, password):
    """This function is called to check if a username /
    password combination is valid.
    """
    return username == my_username and password == my_password
```

Now you can pass in your own username and password when you run your development server:

```bash
$ python bootstrap.py username password
```

That's all there is to adding basic authentication to our app. Next time we'll start looking at using headers sent by Imagr to serve up the customised script to our clients.

And for those following along at home, here's our code after part 1:

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

@app.route('/')
@requires_auth
def index():
return 'Hello World!'

if **name** == '**main**':
app.run(host='0.0.0.0', debug=DEBUG)

```

```
