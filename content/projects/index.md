---
title: Projects
private: true
---

## Sal

![A screenshot of a web dashboard with various charts](/images/projects/Sal.png) [Sal](https://github.com/salopensource/sal) is the multi-tenanted reporting tool for Munki, featuring:

- Full plugin support, allowing for unlimited customisation through the GUI.
- Powerful search capabilities.
- Separation of business units, allowing finely grained access permissions.
- Support for Active Directory (LDAP) and SAML authentication (via Docker images).

## Crypt

![A screenhot of Crypt's UI, saying "This machine must be encrypted. It will reboot shortly after clicking continue."](/images/projects/Crypt.png)[Crypt](https://github.com/grahamgilbert/crypt2) is a FileVault 2 key escrow solution. It is designed to enforce FileVault on your Apple endpoints in a friendlier way for users than the built in methods provide.

- Prevents login until FileVault is enabled via an Auth plugin
- Will delay key escrow until the machine is online, to ensure the key is always escrowed
- Audited access to keys
- Optional two step approval for key access

## Imagr

![A screenshot of Imagr's UI](/images/projects/Imagr.png) [Imagr](https://github.com/grahamgilbert/imagr) is a legacy, open source deployment tool for OS X, designed to be both simple and powerful. It required no special server infrastructure, only requiring a basic web server. This means that it didn't require Apple hardware for the server end, making it more attractive to enterprises.
Features included:

- ASR image restoration
- Package installation
- Ability to run arbitrary scripts
- Included workflows (as well as included workflows as a result of a script)
