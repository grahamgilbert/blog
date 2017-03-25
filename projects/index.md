---
layout: page
title: Projects
---

## Sal
{% img float-right /images/projects/Sal.png 400px %} [Sal](https://github.com/salopensource/sal) is the multi-tenanted reporting tool for Munki, featuring:

* Full plugin support, allowing for unlimited customisation through the GUI.
* Powerful search capabilities.
* Separation of business units, allowing finely grained access permissions.
* Support for Active Directory (LDAP) and SAML authentication (via Docker images).

## Imagr

{% img float-left /images/projects/Imagr.png 400px %} [Imagr](https://github.com/grahamgilbert/imagr) is the open source deployment tool for OS X, designed to be both simple and powerful. It requires no special server infrastructure, only requiring a basic web server. This means that it doesn't require Apple hardware for the server end, making it more attractive to enterprises.
<br class="clear" />Features include:

* ASR image restoration
* Package installation
* Ability to run arbitary scripts
* Included workflows (as well as included workflows as a result of a script)

## Crypt
{% img float-right /images/projects/Crypt.png 400px %}[Crypt](https://github.com/grahamgilbert/crypt2) is a FileVault 2 key escrow solution. It is designed to enforce FileVault on your Apple endpoints in a friendlier way for users than the built in methods provide.

* Prevents login until FileVault is enabled via an Auth plugin
* Will delay key escrow until the machine is online, to ensure the key is always escrowed
* Audited access to keys
* Optional two step approval for key access
