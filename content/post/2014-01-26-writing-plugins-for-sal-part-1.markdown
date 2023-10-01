---
categories:
  - Sal
  - Python
  - Munki
comments: true
date: "2014-01-26T10:01:26Z"
title: "Writing plugins for Sal: Part 1"
---

Writing a plugin for Sal isn't hard. In fact, I'd go so far as to say it's easy. We're going to make a plugin that will flag up any machines that aren't compatible with Mavericks, by using [Tim Sutton's script](https://github.com/timsutton/munki-conditions/blob/master/supported_major_os_upgrades). To start off with, you're going to need to get that script onto your Macs at `/usr/local/munki/conditions`. I'd personally use Puppet for that, but if you're a purely Munki shop, you'll be using a package. [And handily, I've made one](https://github.com/grahamgilbert/macscripts/raw/master/Munki/Condition%20Packages/supported_major_os_upgrades/supported_major_os_upgrades.pkg).

{{< figure class="center" src="/images/posts/2014-01-26/mavcompatibility.png" width="297" height="131" >}}

The convention I'd like everyone to follow is to drop your plugins into the `plugins` directory, in a subdirectory named after yourself - mine are going in `plugins/grahamgilbert`. The plugin we're making today is going in `plugins/grahamgilbert/mavcompatibility`.

## Metadata

The first piece you'll need is a `.yapsy-plugin` file. This contains the metadata for your plugin. It's all pretty self explanatory. This is `plugins/grahamgilbert/mavcompatibility/mavcompatibility.yapsy-plugin`.

```conf
[Core]
Name = MavCompatibility
Module = mavcompatibility

[Documentation]
Author = Graham Gilbert
Version = 0.1
Website = http://grahamgilbert.com
Description = Displays macs that aren't compatible with 10.9.
```

## Now for the meat

Onto the actual plugin. Your plugin is going to be sent at least two pieces of information, possibly three.

- `page`: This will be the page the plugin is going to be shown on. This will either be `front`, `bu_dashboard` or `group_dashboard`. You will need this information later on.
- `machines`: This a collection of machines you are going to need to work on. Depending on the page, this might be all of them, or just a subset from a Business Unit or Machine Group.
- `theid`: If you are displaying your plugin on either a Business Unit page or a Machine Group page, this is the unique ID of that Business Unit or Machine Group.

And in return, your plugin is expected to return two things:

- Some HTML: You plugin needs to return it's output.
- The width of the output: Sal uses [Bootstrap](http://getbootstrap.com/2.3.2/), and it uses a grid system. So Sal can wrap lines properly, you need to tell Sal how many columns your plugin needs. This should be an integer.

That's the 50,000 ft view of a Sal plugin, let's make one. The main thing to remember is that Sal is written in Django, so if you have any problems, looking at [their documentation](https://docs.djangoproject.com/en/1.5/) will help. You can also enable debug logging on your Sal install by uncommenting lines 24 and 25 in `server/views.py` (turn it off when you're done though, it is VERY verbose).

First off, a little about how Sal stores the data you send it. Sal stores Munki's conditions in the Condition table, and for each one, the name and it's data is stored (this is the same for Facts). Munki's conditions can consist of a variety of data types (strings, dates, arrays), so Sal will flatten any arrays it is given into a comma separated list. Each machine will have multiple Conditions and Facts associated with it.

When displaying the plugin, Sal will look for a function called show_widget, passing the information mentioned previously. Don't worry too much about the templates, we'll cover them later.

```py
from yapsy.IPlugin import IPlugin
from yapsy.PluginManager import PluginManager
from django.template import loader, Context
from django.db.models import Count
from server.models import \*

class MavCompatibility(IPlugin):
def show_widget(self, page, machines=None, theid=None):

        if page == 'front':
            t = loader.get_template('grahamgilbert/mavcompatibility/templates/front.html')

        if page == 'bu_dashboard':
            t = loader.get_template('grahamgilbert/mavcompatibility/templates/id.html')

        if page == 'group_dashboard':
            t = loader.get_template('grahamgilbert/mavcompatibility/templates/id.html')


        not_compatible = machines.filter(condition__condition_name='supported_major_os_upgrades').exclude(condition__condition_name='supported_major_os_upgrades', condition__condition_data__contains='10.9').count()

        c = Context({
            'title': '10.9 Compatibility',
            'not_compatible': not_compatible,
            'page': page,
            'theid': theid
        })
        return t.render(c), 3
```

Skip to line 20 - this is where the real work starts. All we're doing is taking the machines we were passed and first off finding the machines that have the condition we're looking for. We then want to remove those that contain 10.9 in that data.

## Templates

Then it's just a case of passing those variables to our template. As we aren't linking our buttons to anything for now, both of our templates will be the same, but we will still make two separate ones as we're going to need them next time.

{% codeblock lang:html+django grahamgilbert/mavcompatibility/templates/front.html %}
{% raw %}

<div class="span3">
    <legend>{{ title }}</legend>
        <a href="#" class="btn btn-danger">
            <span class="bigger"> {{ not_compatible }} </span><br />
            Not Compatible
        </a>
</div>
{% endraw %}
{% endcodeblock %}

Make a file in `templates` called `id.html` with the same content for now - we'll make them different in part two.

We return our plugin on line 28 of `mavcompatibility.py`. First we render the appropriate template, passing it our data, and we return how wide our plugin is - in this case it will take up three columns.

That's it for a basic plugin - we've taken a bunch of machines, filtered them based on a Munki condition, and we've returned the data. But this obviously is lacking - the button doesn't do anything and we still see a big fat zero when all of our machines are 10.9 capable. Anyway, you can get the code so far in my [sal-plugins repository](https://github.com/grahamgilbert/sal-plugins/tree/master/mavcompatibility).

Tune in to part two for the thrilling conclusion!
