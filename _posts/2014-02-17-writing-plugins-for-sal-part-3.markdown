---
layout: post
title: "Writing Plugins for Sal: Part 3"
date: 2014-02-17 21:12:36 +0000
comments: true
categories: 
- Munki
- Python
- Sal
---
We've already got a fairly decent plugin - it shows us how many machines we have that aren't able to run 10.9. However, quite a few people won't have any machines that fall into this category, and just want to know when one manages to sneak under the radar, so let's hide the plugin if we don't need to see it.

## Previously on Lost

In the first part, you might remember that we had to tell Sal how much space our plugin needed. Well, we're going to cover the eventuality of it not needing any space. First off, ``mavcompatibility.py``.

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
        
        if not_compatible:
            size = 3
        else:
            size = 0

        c = Context({
            'title': '10.9 Compatibility',
            'not_compatible': not_compatible,
            'page': page,
            'theid': theid
        })
        return t.render(c), size
        
    def filter_machines(self, machines, data):
        if data == 'notcompatible':
            machines = machines.filter(condition__condition_name='supported_major_os_upgrades').exclude(condition__condition_name='supported_major_os_upgrades', condition__condition_data__contains='10.9')
            title = 'Macs not compatible with OS X 10.9'
        else:
            machines = None
            title = None
        
        return machines, title
{% endcodeblock %}

Take a look at lines 22 - 25. If we get any results from the query on line 20, we're going to be showing the plugin. If there aren't any applicable machines in our inventory, we don't need to show the plugin. We are returning the size to Sal on line 33.  Easy so far.

All that's left to do now is make our templates not do anything if they don't need to.

{% codeblock lang:html+django grahamgilbert/mavcompatibility/templates/front.html %}
{% raw %}
{% if not_compatible > 0 %}
<div class="span3">
    <legend>{{ title }}</legend>
        <a href="{% url 'machine_list_front' 'MavCompatibility' 'notcompatible' %}" class="btn btn-danger">
            <span class="bigger"> {{ not_compatible }} </span><br />
            Not Compatible
        </a>
</div>
{% endif %}
{% endraw %}
{% endcodeblock %}

Notice the if statement on line 1? If the number of machines is 0, we don't need to show anything. You'll need to make a similar change on ``grahamgilbert/mavcompatibility/templates/id.html``.

That's it - a simple plugin for Sal. You can find this completed plugin in my [sal-plugins repository](https://github.com/grahamgilbert/sal-plugins).