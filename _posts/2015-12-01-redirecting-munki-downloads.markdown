---
layout: post
title: Redirecting Munki Downloads
modified:
categories: 
- Munki
- Puppet
- Nginx
date: 2015-12-01T07:09:00+00:00
---

Munki 2.4.0 brought the option to have Munki follow http redirects ([my first contribution to Munki](https://github.com/munki/munki/pull/530)). This allowed you to set Munki to follow redirects to either just HTTPS URLs or all urls. This allows you to get quite clever about where your Munki content is hosted. For example, I have one piece of software that is quite large, and needs to be downloaded by many remote workers as soon as it is released. Whilst I could stand up a server infrastructure to cope with the demand, there are cloud providers such as Amazon's CloudFront that will handle this all much better than I ever could. Of course, this is only available to clients running Munki version 2.4.0 or higher, so I am going to use my configuration management tool of choice (Puppet) to only use this feature on clients that support it, whilst allowing legacy clients to still get the update from the Munki server as they always have done. <!-- more -->

I use Nginx for my Munki server, but you should be able to translate this technique for your server of choice.

First off, if you are using Puppet for this, you will need my [mac_admin module](https://github.com/grahamgilbert/puppet-mac_admin), as it contains a Fact that will return the version of Munki installed on the client - we will use this to target machines that are able to use redirects.

## The profile

The profile was generated with Tim Sutton's excellent [mcxToProfile](https://github.com/timsutton/mcxToProfile) from a pre-configured `/Library/Preferences/ManagedInstalls.plist`:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadContent</key>
            <dict>
                <key>ManagedInstalls</key>
                <dict>
                    <key>Forced</key>
                    <array>
                        <dict>
                            <key>mcx_preference_settings</key>
                            <dict>
                                <key>AdditionalHttpHeaders</key>
                                <array>
                            <string>X-Supports-Munki-Redirects: true</string>
                        </array>
                                <key>FollowHTTPRedirects</key>
                                <string>https</string>
                            </dict>
                        </dict>
                    </array>
                </dict>
            </dict>
            <key>PayloadDisplayName</key>
            <string>Munki HTTP Headers</string>
            <key>PayloadEnabled</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>MCXToProfile.1411efe2-2cc5-4c7f-829f-4f012a1053f4.alacarte.customsettings.3334a546-251b-47dc-85c9-8f52c36bfc8a</string>
            <key>PayloadType</key>
            <string>com.apple.ManagedClient.preferences</string>
            <key>PayloadUUID</key>
            <string>3334a546-251b-47dc-85c9-8f52c36bfc8a</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadDescription</key>
    <string>Included custom settings:
ManagedInstalls

Git revision: 6c7f6a207a</string>
    <key>PayloadDisplayName</key>
    <string>Munki HTTP Header</string>
    <key>PayloadIdentifier</key>
    <string>com.company.munkiheader</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadRemovalDisallowed</key>
    <true/>
    <key>PayloadScope</key>
    <string>System</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>71ef3bc9-8c5b-41c8-b0d7-c2a623434d70</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>
```

This profile will configure two things - it will set Munki to follow redirects to HTTPS URLs (if you want to allow redirects to plain HTTP URLs, you should use `all` as your preference value), and it will also set a custom HTTP header - we'll look at what we use that for later.

## Deploying the settings to compatible Macs

As I mentioned previously, I use Puppet to deploy configuration to my Macs. I'm using Sam Keeley's fork of the [mac_profiles_handler](https://github.com/keeleysam/puppet-mac_profiles_handler) module to deploy the profile, and the `mac_munki_version` fact from the previously mentioned mac_admin module. Using Puppet to deploy the profile allows us to use the `versioncmp` function to compare the version of Munki currently installed with our target version.

``` puppet
class munki_httpheader {
    # If we're equal to 2.4.0 we get 0, if we're greater, we get 1
    if versioncmp($::mac_munki_version, '2.4.0') >= 0 {
        mac_profiles_handler::manage { 'com.company.munkiheader':
            ensure      => present,
            file_source => 'puppet:///modules/munki_httpheader/com.company.munkiheader.mobileconfig',
        }
    }
}
```

If you wanted to configure this using only Munki, you could deliver the profile using Munki with a conditional item, but you would need to update the condition every time a major version comes out as Munki isn't able to work out if the version is greater or not, so we would need to do multiple `munki_version LIKE` statements.

``` xml
<key>conditional_items</key>
<array>
    <dict>
        <key>condition</key>
        <string>munki_version LIKE '*2.4.0*'</string>
        <key>managed_installs</key>
        <array>
            <string>AdditionalMunkiHeaderProfile</string>
        </array>
    </dict>
</array>
```

## The web server

The reason for the additional HTTP header is that we need to tell Nginx that the client is capable of following HTTP redirects. If we just redirected blindly, clients that aren't running Munki 2.4.0 will fail to download anything (which is clearly not fantastic).

``` nginx
map $http_x_supports_munki_redirects $supports_redirects {
    default "0";
    true    "1";
}

server {
        if ($supports_redirects) {
            rewrite ^/pkgs/apps/ToRedirect/(.+) https://company.cloudfront.net/pkgs/apps/ToRedirect/$1 redirect;
        }
# The rest of your nginx config will go here
}
```

This allows us to redirect any packages that are in `/pkgs/apps/ToRedirect` if the client is capble of following the redirect - if they aren't, they will carry on and read the rest of the configuration and get the file directly from the main web server.