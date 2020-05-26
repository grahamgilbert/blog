---
categories:
- Python
- Puppet
date: "2017-04-21T11:20:38Z"
title: Using Python in Puppet Facts
---

There comes a time when writing Facts in Ruby just isn't going to cut it - when you need to access Objective C frameworks, for example. Whilst Ruby can't access these, Python is waiting in the wings ready to come to your rescue.

There is the concept of [External Facts](https://docs.puppet.com/facter/3.6/custom_facts.html#what-are-external-facts) - Facts that are written in whatever the system can run, and with Puppet 3.4 / Facter 2.0.1, they can even be distributed with [pluginsync](https://docs.puppet.com/puppet/4.10/plugins_in_modules.html#auto-download-of-agent-side-plugins-pluginsync).

So let's say you wanted a Fact that reported what a preference is set to (the GlobalProtect VPN client's portal in this example):

``` python facts.d/global_protect_portal_pref.py
#!/usr/bin/python

import Foundation
import sys

value = Foundation.CFPreferencesCopyAppValue('Portal', 'com.paloaltonetworks.GlobalProtect')
out = value or ''
sys.stdout.write(out)
```

All done, right? Well, until you try to run this on a box without the Python Objective-C bridge, anyway. Like you Linux machines that also use this Puppet Server.

We've hit one of the drawbacks of External Facts vs regular Facts in that you can't confine your Fact to a particular operating system (you are also unable to access the values from other Facts).

Fortunately, Facter can execute shell commands. And you can feed in strings at the command line for `/usr/bin/python` to run for you.

``` ruby lib/facter/global_protect_portal_pref.rb
# global_protect_portal_pref.rb
Facter.add(:global_protect_portal_pref) do
  confine kernel: 'Darwin'
  setcode do
    portal = nil
    output = Facter::Util::Resolution.exec("/usr/bin/python -c \"import Foundation; import sys; value = Foundation.CFPreferencesCopyAppValue('Portal', 'com.paloaltonetworks.GlobalProtect'); out = value or ''; sys.stdout.write(out);\"")
    if output != ''
      portal = output
    end
    portal
  end
end
```

With this pattern, we are able to use values from other Facts, and we can confine where our Fact will run so we don't get errors on operating systems that don't support what we're doing.
