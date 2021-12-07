+++
date = 2020-11-13T12:00:00Z
lastmod = 2020-11-13T12:00:00Z
title = "Installing Rosetta 2 on Apple Silicon Macs"
+++

Our bootstrap tool is written in [Go](https://golang.org/), and as of the time I'm writing this, Go doesn't support building for Apple Silicon Macs.

As such, we need to ensure Rosetta 2 is installed for our enrollment process to work. The only problem I had was that we only wanted to run this on Apple Silicon devices - obviously Intel Macs don't need this. I learned about `/usr/bin/arch` this morning, which led to the script below:

```bash
#!/bin/bash

arch=$(/usr/bin/arch)

if [ "$arch" == "arm64" ]; then
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi
```

This works fine as root (we run it from a Launch Daemon), and I expect it would be fine in a payload free package as well.
