---
categories:
- OS X
- Packaging
- AutoPkg
comments: true
date: "2014-06-30T10:12:10Z"
title: Making packages with AutoPkg
---
Over the past few weeks, I've had the same conversation over and over:
people telling me that once they get started using Munki, their next
step will be to start using AutoPkg. I gave each person the same
response: "you're doing it wrong".

AutoPkg a has a reputation of being difficult to use. This is totally
unjustfied. You don't need to be using Munki for it to be useful, you
don't need to set it up to run automatically via Jenkins or a
LaunchDaemon. If you need to get software into a package,  AutoPkg is
the easiest way.

## Installing AutoPkg

Head over to the [releases page on AutoPkg's GitHub repository](https://github.com/autopkg/autopkg/releases/latest) and
download the latest version  (0.3.0 at the time of writing). It's an
Apple package, so double click it and get it installed. If you have Gate Keeper enabled, you'll need to right-click on the package and choose to install it from there, as it's not been signed.

## Recipes

AutoPkg is useless without recipes. Fortunately, there are hundreds
that have already been made by the community.

We'll add the set of recipes maintained by AutoPkg's authors, which
contains some of the most common software. Open up a terminal window
and enter :

```sh
$ autopkg repo-add https://github.com/autopkg/recipes
```

You'll see AutoPkg downloading and adding the recipes to your Mac.

```sh
Attempting git clone...

Adding /Users/grahamgilbert/Library/AutoPkg/RecipeRepos/com.github.autopkg.recipes to RECIPE_SEARCH_DIRS...
Updated search path:
  '.'
  '~/Library/AutoPkg/Recipes'
  '/Library/AutoPkg/Recipes'
  '/Users/vagrant/Library/AutoPkg/RecipeRepos/com.github.autopkg.recipes'
```


## Using the thing

Let's see what recipes we just added. Still in your terminal, enter:

```sh
$ autopkg list-recipes
```

You'll see a whole load of output like:

```sh
Adium.download
Adium.munki
Adium.pkg
AdobeAIR.pkg
AdobeAcrobatPro9Update.download
AdobeAcrobatPro9Update.munki
AdobeAcrobatProXUpdate.download
AdobeAcrobatProXUpdate.munki
AdobeAir.munki
AdobeFlashPlayer.download
AdobeFlashPlayer.munki
AdobeFlashPlayer.pkg
AdobeFlashPlayerExtractPackage.munki
...
```

The naming convention in AutoPKG is SoftwareName.output. For for
example, to run a recipe that downloads Google Chrome and adds it to
Munki, you would use the GoogleChrome.munki recipe, but if you just
wanted to download it an make a package, you'd use the GoogleChrome.pkg recipe. It just so happens that making a package of Chrome is exactly what we want to do.

Back into your terminal and enter:

```sh
$ autopkg run GoogleChrome.pkg
```

The AutoPkg robot will churn away and you'll get some output similar to:

```sh
Processing GoogleChrome.pkg...

The following new items were downloaded:
    /Users/grahamgilbert/Library/AutoPkg/Cache/com.github.autopkg.pkg.googlechrome/downloads/GoogleChrome.dmg

The following packages were built:
    Identifier               Version          Pkg path
    ----------               -------          --------
    com.google.Chrome        35.0.1916.153    /Users/grahamgilbert/Library/AutoPkg/Cache/com.github.autopkg.pkg.googlechrome/GoogleChrome-35.0.1916.153.pkg
```

And when it's all finished, you'll be left with a nice package that
you can use anywhere you'd use finely crafted packages - ARD, AutoDMG or even Casper if you're that way inclined (although Allister Banks has been
working on a way of automating importing packages into the JSS - see
his [recent talk](http://tmblr.co/ZHT_Wy1J-Hk5I) for more on that subject).

## Doing it all again

What happens next time you want to build an updated package?

```sh
$ autopkg run GoogleChrome.pkg
```

Right?

Well, kinda.

What happens if Google changes the URL AutoPkg uses to download
Chrome? Fortunately we're using the community provided recipes, and if
something's broken they usually get fixed pretty quickly. We just need
to tell AutoPkg to update the installed recipes.

```sh
$ autopkg update-repo all
```

And then we're able to build our package safe in the knowledge that
someone else has done all of the hard work for us.
