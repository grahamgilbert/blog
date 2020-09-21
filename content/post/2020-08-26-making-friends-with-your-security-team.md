+++
date = 2020-08-26T13:00:00Z
lastmod = 2020-08-26T13:00:00Z
title = "Making friends with your security team"
+++

First off, let’s talk about the elephant in the room: most endpoint engineers do not get on with their security team. You will often hear complaints like

> Our security team wants us to deploy terrible product X.

> Product X is destroying our CPUs / causing kernel panics.

> Security has no idea what they’re doing.

Let’s see how we can overcome these issues and work more closely with our security team.

## Step 1: assume good intent

It may well be that your security team comes to work thinking "I’m going to make all of our user’s lives miserable today", keeping score of the number of times they take down someone’s computer. If that’s the case, then you’re probably out of luck. What is more likely is that they, like you, are just trying to do the right thing. They are trying to do their best to maintain a security posture with the tools that they have available to them. Which leads us onto...

## Step 2: education

When you are asked to deploy `terrible product X`, before complaining about it, a better first step is to ask your security team (to paraphrase Mr Neagle) "what are you trying to achieve?".

They may just be looking for some visibility into the fleet - what operating system it’s running, whether the device is encrypted, if it has a password set - basic security stuff. And all things that practically any endpoint management tool can provide. If this is all they require, then certainly consider giving them access to those metrics. Perhaps they use an [SIEM](https://en.wikipedia.org/wiki/Security_information_and_event_management) and would like the data to be piped into there - if your management tool has an API, it is probably less work to build out a simple script that ships the data to where they need than test yet another kernel extension.

And if they do insist that they need their tool installed because your data doesn’t meet all of their needs, work with them to first validate the tool - and I don’t just mean that it gets all of the data they need. You should use your platform knowledge to help your security team develop a framework to evaluate these tools. Your security team may not work on endpoints full time, and they almost certainly don’t have the same knowledge you do. Perhaps they don’t know that Kernel Extensions have been deprecated in favor of System Extensions. Maybe they don’t realize that you don’t need a Kernel Extension to read every file on the disk, merely a whitelist via an MDM profile. Use your expertise to help them make the right decision.

## Step 3: data wins arguments

If you already have `terrible product X` installed, start collecting data on _why_ it's terrible. What percentage of your fleet is having kernel panics thanks to it? How much CPU or memory is it eating? How badly does it impact software builds (if you support iOS developers, definitely check this one - we have seen some products cause builds to take up to 20x longer). If you don't have a good way to measure these metrics, you should consider deploying [osquery](https://osquery.io/), so you could run a query such as:

```
# Track the percentage of total CPU time utilized by $endpoint_security_tool
osquery> SELECT ((tool_time*100)/(SUM(system_time) + SUM(user_time))) \
AS pct FROM processes, (SELECT (SUM(processes.system_time)+\
SUM(processes.user_time)) AS tool_time \
FROM processes WHERE name='endpoint_security_tool');
+-----+
| pct |
+-----+
| 32  |
+-----+
```

The cost of running software isn't only the sticker price. If `terrible product X` is causing users to be negatively impacted in a measurable way, your security team should be more willing to work with you to find a solution.

## Step 4: sharing is caring

We’ve already covered that perhaps you may want to share your data with your security team. Have you ever considered asking for access to theirs? A lot of threat detection tools can also make great endpoint management tools. Here’s a little case study:

A few years back, our security team deployed [osquery](https://osquery.io/) to monitor our endpoints. They also developed [StreamAlert](https://www.streamalert.io/) to process and alert on the data. We helped them deploy it, and moved on. It wasn’t until we had beers after work one day with some of the security engineers that we thought of it again. We were talking about writing some tool to capture logs from devices (I forget which). The person from security mentioned that they got all of that from osquery. Fast forward to 2020 and osquery is now our primary method of retrieving data from our endpoints. We’ve even written our own extension (you can find most of it on [GitHub](https://github.com/macadmins/osquery-extension)) to help retrieve the data we care about.

When we were evaluating tools that could alert us if our management tools started failing (i.e. Munki runs began failing), we could use [Sal](https://github.com/salopensource/sal), hook it up to an automation that checked whether the devices with errors exceeded a certain percentage of successful devices and page the person that is currently on call. All definitely possible, but would require quite a bit of work.

We knew that our security team had a pipeline with StreamAlert set up that would alert them if certain criteria were met. Why should we reinvent the wheel? So we reached out to them, and the only reason we didn’t have access was because they thought we wouldn’t be interested in it. Half an hour later we had written our first rule and got it into production.

## The moral of this story

We all ultimately want the same thing - to keep our organizations productive. Whether we do that by providing software and configuration or whether we do that by keeping our fleet secure, our goals are the same. By sharing knowledge, data and tools with your security teams, everyone can benefit.
