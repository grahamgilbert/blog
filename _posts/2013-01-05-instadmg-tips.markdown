---
layout: post
title: "InstaDMG Tips"
date: 2013-01-05 14:35
comments: true
categories: 
- OS X
- Deployment
- InstaDMG
---
I've been using [InstaDMG](http://code.google.com/p/instadmg/) for nearly two years now. We all know it's awesome (if you aren't aware of it's awesomeness, I suggest taking a look at [Allister Banks' talk at PSU MacAdmins last year](http://www.youtube.com/watch?v=o8xtO5E4MzE)). I'm almost ashamed to admit that I was happily making my Golden Master images on my test iMac and hoping for the best when I cleaned them up by hand and pushed them out. Anyway, that's enough of my admissions. Over these two years, I've picked up a few tips and tricks for working effectively with InstaDMG.

##Put an SSD in your laptop
Seriously, just do it. If your boss complains at how much it costs, then they're not charging enough for you. The price of the SSD was covered by the time I saved when doing one particularly chunky build (around 30GB including packages). InstaDMG is primarily I/O bound, so an SSD will change your InstaDMG life.

##Keep your InstaUp2DatePackages on a web server
If you've got more than one person building images in your organisation, you'll soon find that your packages will get out of sync with each other. One person will be using 0.8.2 of Munki, another 0.8.3, it all goes horribly wrong. As InstaDMG can pull packages from a web server, this lends itself to having a central repository for packages in your oganisation. Remember to keep it safely behind your firewall if you've got sensitive info in your packages (like one that creates your admin user, for example).

##Keep our CatalogFiles in source control
Now that everyone has access to your InstaUp2DatePackages, we ought to get our CatalogFiles in check too. Keep them in some sort of source control like [Git](http://grahamgilbert.com/blog/2012/09/21/five-reasons-sysadmins-should-use-git/) and be happy. Mine can be found on my [GitHub](https://github.com/grahamgilbert/InstaDMG-Catalogs).