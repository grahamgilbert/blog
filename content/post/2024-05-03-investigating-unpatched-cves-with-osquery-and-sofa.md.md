+++
date = 2024-05-03T09:00:00Z
lastmod = 2024-05-03T09:00:00Z
title = "Investigating unpatched CVEs with osquery and SOFA"
categories = ["osquery", "security", "opensource"]
+++

This week, [Mac Admins Open Source](https://macadmins.io) released a new tool called [SOFA](https://github.com/macadmins/sofa). SOFA is a machine readable feed of macOS and iOS update data - including CVEs. Of course, my mind immediately jumped to "this would be a great osquery table", so the [macadmins osquery extension](https://github.com/macadmins/osquery-extension) was updated this week to include tables for both the security release information for macOS (`sofa_security_release_info`) and unpatched CVEs (`sofa_unpatched_cves`).

In this post, I'll show you how to use the new `sofa_unpatched_cves` table to investigate unpatched CVEs on your macOS fleet.

## Getting started

Assuming you have [osquery](https://osquery.io) installed, download the latest version of the [macadmins osquery extension](https://github.com/macadmins/osquery-extension/releases), unzip it and place it somewhere on your disk. Then open up a shell and:

```shell

osqueryi --extension /path/to/macadmins_extension/darwin/macadmins_extension.ext

```

The above is only for testing purposes. For production use, you should consult the [osquery documentation](https://osquery.readthedocs.io/en/stable/deployment/extensions/).

## Let's go

First off, make sure the tables are loaded:

```sql
osquery> .tables
[snip]
  => sofa_security_release_info
  => sofa_unpatched_cves
[snip]
```

Now let's query for some security release information:

```sql
# set osquery to line output mode
.mode line
osquery> select * from sofa_security_release_info;
                update_name = macOS Sonoma 14.4.1
            product_version = 14.4.1
               release_date = 2024-03-25T00:00:00Z
              security_info = https://support.apple.com/kb/HT214096
          unique_cves_count = 1
days_since_previous_release = 18
                 os_version = 14.4.1
```

I'm running macOS 14.4.1 (the latest version at the time of writing), but what if I wanted to look up the security information for older versions? I can do that with the `sofa_security_release_info` table:

```sql
osquery> select * from sofa_security_release_info where os_version = '14.4';
                update_name = macOS Sonoma 14.4.1
            product_version = 14.4.1
               release_date = 2024-03-25T00:00:00Z
              security_info = https://support.apple.com/kb/HT214096
          unique_cves_count = 1
days_since_previous_release = 18
                 os_version = 14.4

                update_name = macOS Sonoma 14.4
            product_version = 14.4
               release_date = 2024-03-07T00:00:00Z
              security_info = https://support.apple.com/kb/HT214084
          unique_cves_count = 67
days_since_previous_release = 28
                 os_version = 14.4
```

## Am I vulnerable?

Security release information is interesting and all, but what about those unpatched CVEs? Let's take a look:

```sql
osquery> select * from sofa_unpatched_cves;
osquery>
```

Of course, I'm fully patched. But what if I wasn't? Let's take a look at the unpatched CVEs for macOS 14.4:

```sql
osquery> select * from sofa_unpatched_cves where os_version = '14.4';
        os_version = 14.4
               cve = CVE-2024-1580
   patched_version = 14.4.1
actively_exploited = false
```

So we can see what CVEs are patched in the 14.4.1 release. Fortunately none of those are known to have been actively exploited at the time of the release. But osquery is great at answering all sorts of questions. What if I were running macOS 14.3 and I wanted to know which CVEs were actively exploited?

```sql
osquery> select * from sofa_unpatched_cves where os_version = '14.3' AND actively_exploited="true";
        os_version = 14.3
               cve = CVE-2024-23225
   patched_version = 14.4
actively_exploited = true

        os_version = 14.3
               cve = CVE-2024-23296
   patched_version = 14.4
actively_exploited = true
```

## Wrapping up

Searching back over macOS release history is interesting, but the real power of this table is in monitoring your fleet for unpatched CVEs. I have the following queries running across my fleet allowing us to make a good assesment of our security posture:

```sql
# Find all unpatched CVEs
SELECT * FROM sofa_unpatched_cves;

# Find all actively exploited CVEs
SELECT * FROM sofa_unpatched_cves WHERE actively_exploited='true';
```
