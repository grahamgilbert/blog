---
categories:
- Puppet
- Mac OS X
comments: true
date: "2012-08-18T00:00:00Z"
title: Location based printers with Puppet
---
This will probably be obvious to most seasoned Puppet inclined OS X admins, but this is a relatively recent revelation for me. Up until very recently, I wasn't really making full use of Facter, merely pointing my clients to the appropriate classes and leaving it at that. When tasked with giving end users the option to install their own printers when they went to a different site than the one they usually work at, my initial thought was to go for a Payload-free package and pop it into their optional installs in Munki. But then I was asked if it could happen without the user doing anything - they go to the other site, and they automatically get the right printers set up - so after a little thought,  came up with this. I've made use of the excellent [mosen-puppet-cups](https://github.com/mosen/puppet-cups) module on GitHub to get the printers set up, and the drivers are already deployed with Munki (I did consider moving them to Puppet, but why reinvent the wheel for the sake of it?).

```
case $operatingsystem{
	Darwin:{
		##London is on the 10.30.2.0 and 10.30.3.0 Subnets
		if ($network_en0 == '10.30.2.0') or ($network_en1 == '10.30.2.0') or ($network_en0 == '10.30.3.0') or ($network_en1 == '10.30.3.0'){
            	printer { "Sharp_ARM316":
                	ensure      => present,
			uri         => "lpd://sharparm316.ldn.example.com",
			description => "Sharp ARM316",
			shared      => false,
			ppd         => "/Library/Printers/PPDs/Contents/Resources/SHARP AR-M316.PPD.gz", # PPD file will be autorequired
			}
		printer { "Xerox_WorkCentre_7120":
			ensure      => present,
			uri         => "lpd://xeroxwc7120.ldn.example.com",
			description => "Xerox WorkCentre 7120",
			shared      => false,
			ppd         => "/Library/Printers/PPDs/Contents/Resources/Xerox WorkCentre 7120.gz", # PPD file will be autorequired
			}
		}

		##San Francisco is on the 10.30.10.0 Subnet
		if ($network_en0 == '10.30.10.0') or ($network_en1 == '10.30.10.0'){
 		printer { "Xerox_550":
			ensure      => present,
			uri         => "lpd://xerox550.sf.example.com",
			description => "Xerox 550",
			shared      => false,
			ppd         => "/Library/Printers/PPDs/Contents/Resources/en.lproj/Xerox 550-560 Integrated Fiery", # PPD file will be autorequired
			}
		}
	}
}
```
