---
title: Introducing MDMDirector
date: 2019-12-19T10:30:46-00:00
categories:
  - MDMDirector
  - MicroMDM
  - MDM
  - Opensource
---

At work, we're great fans of MicroMDM. It's lightweight, it's all driven via an API so we can configure it with code - it has nearly everything we want. But unfortunately, it doesn't have everything - as Groob himself says, ["it's not a product"](https://github.com/micromdm/micromdm/blob/master/docs/user-guide/introduction.md#not-a-product) - this means it purposely doesn't include some of the things you may need from an MDM.

This is where [MDMDirector](https://github.com/mdmdirector/mdmdirector) comes in.

MDMDirector is able to receive the data from MicroMDM from it's [webhook feature](https://github.com/micromdm/micromdm/wiki/Webhooks) and then take action based on the data it receives. Perhaps you need to ensure a profile is of a certain version on all of your devices? MDMDirector has you covered. What about via a REST API? We definitely do that too. Would you like to retrieve `SecurityInfo` or `CertificateList` from the machines regularly? Yep, can do that as well.

MDMDirector is most definitely opinionated - it was written to support the workflow we have at my employer - which means it may not be for everyone. It purposely doesn't include a GUI as it is designed to be driven by automation tools like your Configuration Management tool or a CI/CD tool. For the same reason, it doesn't have any other logical groupings other than all machines or one machine - something else is managing that part of the puzzle.

What MDMDirector will give you is a tool to orchestrate MicroMDM in a programmatic fashion - if those words make a lightbulb go `ping` in your head, head over to [GitHub](https://github.com/mdmdirector/mdmdirector) and open issues and pull requests so we can make MDMDirector better.
