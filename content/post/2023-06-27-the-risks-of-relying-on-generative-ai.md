+++
date = 2023-06-27T12:00:00Z
lastmod = 2023-06-27T12:00:00Z
title = "The risks of relying on Generative AI"
categories = ["AI", "scripting", "security"]
+++

This morning I saw a major MDM vendor advertising an upcoming feature that will write scripts to manage your macOS devices for you using generatice AI - sounds like the end of our profession, right?

Let's look at an example of a common IT task - keeping Chrome on macOS up to date. I asked [ChatGTP](https://chat.openai.com) to "Write me a script to keep Google Chrome updated on macOS".

It returned the following:

``` bash
#!/bin/bash

# Path to Google Chrome executable
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Function to check for and install Chrome updates
check_and_install_updates() {
    # Check for updates and get the version
    LATEST_VERSION=$(curl -s "https://omahaproxy.appspot.com/all?os=mac" | grep -m 1 stableversion | cut -d '"' -f 2)
    CURRENT_VERSION=$("$CHROME_PATH" --version | awk '{print $3}')
    
    # Compare versions
    if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
        echo "A new version of Google Chrome is available. Updating..."
        
        # Download the latest version
        curl -O "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
        
        # Mount the downloaded DMG file
        hdiutil attach googlechrome.dmg
        
        # Install the update
        sudo "/Volumes/Google Chrome/Google Chrome.app/Contents/MacOS/Google Chrome" --update
        
        # Eject the mounted DMG file
        hdiutil eject "/Volumes/Google Chrome"
        
        # Clean up the downloaded DMG file
        rm googlechrome.dmg
        
        echo "Google Chrome updated to version $LATEST_VERSION."
    else
        echo "Google Chrome is already up to date (version $CURRENT_VERSION)."
    fi
}

# Run the update check and install updates if available
check_and_install_updates
```

It also told me to save it somewhere on my computer, and make it executable (`chmod +x chrome_update.sh`) and then run it with `sudo ./chrome_update`.

So here is our first problem - `sudo "/Volumes/Google Chrome/Google Chrome.app/Contents/MacOS/Google Chrome" --update` - if we are already running the script with elevated permissions, why do we need to sudo again?

Regardless, I ran the script as instructed. I saw my the disk image being downloaded in my terminal, I saw the disk image being mounted and opened in the Finder (a great user experience if you were doing this with your management tool), I saw a second instance of Chrome open (the user experience just keeps getting better) and then... Nothing. I've never seen the `update` flag on Google Chrome - maybe it existed at some point, maybe I'm using it wrong. Regardless the script didn't actually do anything useful.

And here is the even more terrifying security issue - the script is telling you to `curl` something from the public internet, and then run code as the `root` user. Dear reader, you may be thinking "but the disk image was downloaded from Google's website!" - and you would be right. But we do not know the state of the device that we are running this script on, it could have malware, it could have a dodgy root certificate authority installed that would trust a certificate issuer that isn't Google - all sorts of things could have happened.

Perhaps I wasn't specific enough - I asked "Write a script to keep Google Chrome updated on macOS using a management tool that runs as root".

``` bash
#!/bin/bash

# Check if softwareupdate binary exists
if ! command -v softwareupdate &> /dev/null; then
    echo "softwareupdate binary not found. Please make sure the system software is up to date."
    exit 1
fi

# Check for Google Chrome updates
chrome_updates=$(softwareupdate -l | grep "Google Chrome")
if [[ -z "$chrome_updates" ]]; then
    echo "No Google Chrome updates available."
else
    echo "Google Chrome updates found. Installing..."
    sudo softwareupdate --install "$chrome_updates"
    echo "Google Chrome updates installed."
fi
```

Installing Google Chrome via `softwareupdate` isn't a thing unfortunately, as much as it would be nice to have an Apple provided way of keeping third party software up to date. I also have access to GPT-4 - perhaps a newer model will produce a better result? Unfortunately it's answer was only slightly better, in that it might actually work - but it did involve requiring [homebrew](https://brew.sh) to be installed.

So back to my original point - AI can be a great starting point for writing code, but at the moment at least, it is definitely not a "no code" solution. It defintiely does not replace knowing how to write code yet, and you should exercise caution before running any code produced by it.
