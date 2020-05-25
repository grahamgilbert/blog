---
categories:
- Munki
- Python
- Automation
comments: true
date: "2015-02-11T12:11:30Z"
title: Managing Munki catalogs with Trello
---
Over the past few months, I've been trying to take small pieces of our workflow and see if we can expand on the number of people able to manage it. We've got [AutoPkg](https://github.com/autopkg/autopkg) populating our [Munki](https://github.com/munki/munki) repositories without any manual intervention, but we still need to edit pkgsinfo files to move items through development to testing to production catalogs. Sure, there are existing tools  like [MunkiWebAdmin](https://github.com/munki/munkiwebadmin) or [MunkiAdmin](https://github.com/hjuutilainen/munkiadmin), but they either still require knowledge of how Munki works or full access to the repository via a file share of some sort. And we obviously already have a tool for assigning software to machines in Sal+ - we needed something that can speed this incredibly common task.

Then I cast my mind back to a conversation I had with [Pepijn Bruienne](https://twitter.com/bruienne) at PSU last year about his workflow using [Trello](https://trello.com) to promote items in his Munki repository. So, after pestering him for some information, I devised a workflow that matched how we worked. 

## "So how does it work", I hear you cry

We have five lists on our "Munki Package Management" Trello board. Essentially when the script runs, it inspects the items in our Munki catalog and if they're not already in the Trello board, it adds them to the correct list (we ignore anything that's already in production. All promotions to production are done using this tool now). 

{{< figure class="center" src="/images/posts/2015-02-11/to_testing.gif" width="427" height="240" >}}

We also have lists called "To Development", "To Testing" and "To Production". Moving items into these lists will be caught by the script next time it runs, and moved to the appropriate catalog. 

{{< figure class="center" src="/images/posts/2015-02-11/testing.gif" width="427" height="240" >}}

When items finally make it to Production, we add them to a dated Production list. This allows us to have a full history of when things are added to Production and who has moved it through each stage. We're also big users of Slack, so we hooked up it's Tello integration to post a message to our notficiations channel to let our team know when items are added into Munki.

You can grab the script from [pebble.it's GitHub account](https://github.com/pebbleit/munki-trello), or if you're Docker inclined there's a [container that has everything you need](https://registry.hub.docker.com/u/pebbleit/munki-trello/).