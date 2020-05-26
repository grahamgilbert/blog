---
categories:
- Munki
- Python
- Sal
comments: true
date: "2014-02-07T11:34:24Z"
title: 'Writing Plugins for Sal: Part 2'
---
And now, time for the shocking second part of our series on how to write plugins for Sal.

In the previous part, we got our basic widget working. This time, we're going to link it up so we can get lists of those pesky non-10.9 compatible Macs when we click on the button.

## It's a list, Jim

When displaying the list of machines, Sal will call the ``filter_machines`` function in your plugin. I'm sure you don't want to disappoint, so here's that function added on to the plugin we wrote last time.

{% codeblock grahamgilbert/mavcompatibility/mavcompatibility.py %}
from yapsy.IPlugin import IPlugin
from yapsy.PluginManager import PluginManager
from django.template import loader, Context
from django.db.models import Count
from server.models import *

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
        
    def filter_machines(self, machines, data):
        if data == 'notcompatible':
            machines = machines.filter(condition__condition_name='supported_major_os_upgrades').exclude(condition__condition_name='supported_major_os_upgrades', condition__condition_data__contains='10.9')
            title = 'Macs not compatible with OS X 10.9'
        else:
            machines = None
            title = None
        
        return machines, title
{% endcodeblock %}

You'll notice that our filter on the machines is pretty much identical to what we were looking for before - that's because we're looking for the same machines. We're taking some input (a bunch of machines, and a string that we'll come back to), and giving back the machine that fit our search and a title to show at the top of the page.

## More templating

So, how did we pass that string? How do we even get to the page where a list of the machines is shown?

We need to edit the templates. First off, the template that is show on the front page of Sal:

{% codeblock lang:html+django grahamgilbert/mavcompatibility/templates/front.html %}
{% raw %}
<div class="span3">
    <legend>{{ title }}</legend>
        <a href="{% url 'machine_list_front' 'MavCompatibility' 'notcompatible' %}" class="btn btn-danger">
            <span class="bigger"> {{ not_compatible }} </span><br />
            Not Compatible
        </a>
</div>
{% endraw %}
{% endcodeblock %}

The only difference here from last time is we've filled out the URL. The options for the first part are ``machine_list_front`` or ``machine_list_id`` - depending on whether you are coming from the front page (all of the Business Units) or from deeper in the application (the machines are limited), then we're just passing the name of our plugin.

There isn't a huge amount you need to change for the other template - just tell Sal what type of page you came from (group or business unit) and the ID of the page you came from.

{% codeblock lang:html+django grahamgilbert/mavcompatibility/templates/id.html %}
{% raw %}
<div class="span3">
    <legend>{{ title }}</legend>
        <a href="{% url 'machine_list_id' 'MavCompatibility' 'notcompatible' page theid %}" class="btn btn-danger">
            <span class="bigger"> {{ not_compatible }} </span><br />
            Not Compatible
        </a>
</div>
{% endraw %}
{% endcodeblock %}

There you go - a simple plugin for Sal. But don't go away thinking we're done. Whilst this is functional, it certainly leaves a fair bit to be desired. In the last part of this series, we'll tidy everything up.