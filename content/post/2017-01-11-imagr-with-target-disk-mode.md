---
categories:
- Imagr
date: "2017-01-11T14:47:43Z"
title: Imagr with target disk mode
---
[Imagr](https://github.com/grahamgilbert/imagr) is a great tool when you're wanting to deploy machines quickly in your office. But sometimes you will want to deploy machines when you're in a smaller remote site, or a site where security concerns mean you can't have servers. Imagr is flexible enough to handle this, and with a little creativity, we can deploy at these sites as easily as we can at our offices with NetBoot.

## Setup

The first thing you are going to want to do it get your Imagr repo onto your own machine. I would recommend having your repo in a central repository - [git fat](https://www.afp548.com/2014/11/24/introduction-to-git-fat-for-munki/) works well, so does putting everything on an [S3 bucket](https://aws.amazon.com/s3/) and using the [aws cli tools](https://aws.amazon.com/cli/) to sync it down. We use an S3 bucket, as we can ship read only credentials to the machines that are performing the imaging. This guide will assume you are using S3, but you can substitute that aspect for whichever method you wish to sync your files. <!--more-->

You will also need to place [Imagr.app](https://github.com/grahamgilbert/imagr/releases) on the machine somewhere, and [point it to your configuration file](https://github.com/grahamgilbert/imagr/wiki/App-Config). The configuration file can be on a web server (as it's tiny, it will only take a second to download), or it can be on your local disk.

## The wrapper script

Imagr was originally designed to be run from a NetInstall / NetBoot environment - this means that it is running as root. To ensure that the people performing the imaging don't open it as a user without the right permissions, we use a wrapper script. This script is also a great place for you to put the code that syncs the code down to the local machine, to ensure your techs are using the latest version of your repo. The following script assumes that:

* The aws cli tools are installed (`sudo easy_install awscli`)
* You have Imagr.app in `/Applications`
* You will be storing the Imagr repo at `/usr/local/imagr`

The below script will:

* Download sync your local copy of the Imagr repo with what is in S3
* Make sure there is a writable disk available, with Preserve Ownership enabled
* Open Imagr.app as root

``` python /usr/local/bin/imagr
#!/usr/bin/python

import subprocess
import os
import filecmp
import shutil
import sys
import plistlib
import pprint

def main():

    if os.getuid() != 0:
        print 'You need to run this as root or via sudo.'
        sys.exit(1)

    if not os.path.exists('/usr/local/imagr'):
        os.makedirs('/usr/local/imagr')
        print 'Creating Imagr repo. The initial download may take some time.'

    os.environ['AWS_ACCESS_KEY_ID'] = "YOUR ACCESS KEY"
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'YOUR ACCESS SECRET'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    s3_bucket_url = 'YOUR S3 BUCKET' # in the form of s3://somebucketname

    cmd = ['/usr/local/bin/aws', 's3', 'sync', s3_bucket_url, '/usr/local/imagr/', '--exclude', '.git/*', '--delete']
    for line in execute(cmd):
        print line

    diskutil_list = subprocess.check_output(['/usr/sbin/diskutil', 'list', '-plist'])
    diskutil_plist = plistlib.readPlistFromString(diskutil_list)

    for disk in diskutil_plist['AllDisks']:
        disk_info = subprocess.check_output(['/usr/sbin/diskutil', 'info', '-plist', disk])
        disk_plist = plistlib.readPlistFromString(disk_info)
        if disk_plist['VolumeName'] != 'Recovery HD' and \
        disk_plist['Internal'] == False and \
        disk_plist['MountPoint'] != '':
            if disk_plist['GlobalPermissionsEnabled'] == False:
                try:
                    subprocess.call(['/usr/sbin/vsdbutil', '-a', disk_plist['MountPoint']])
                except:
                    print 'Could not enable Ownership'

    # Run diskutil again
    diskutil_list = subprocess.check_output(['/usr/sbin/diskutil', 'list', '-plist'])
    diskutil_plist = plistlib.readPlistFromString(diskutil_list)
    good_disks = 0
    # See if there is at least one disk that satisfies our crieria above (+ ownership enabled)
    for disk in diskutil_plist['AllDisks']:
        disk_info = subprocess.check_output(['/usr/sbin/diskutil', 'info', '-plist', disk])
        disk_plist = plistlib.readPlistFromString(disk_info)
        if disk_plist['VolumeName'] != 'Recovery HD' and \
        disk_plist['Internal'] == False and \
        disk_plist['MountPoint'] != '' and \
        disk_plist['GlobalPermissionsEnabled'] == True:
            good_disks += 1

    if good_disks == 0:
        print 'We couldn\'t find any disks that are external and have ignore permissions disabled.'
        print 'Please make sure the disk is attached before running this script.'
        sys.exit(1)

    subprocess.call(['/Applications/Imagr.app/Contents/MacOS/Imagr'])

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    stdout_lines = iter(popen.stdout.readline, "")
    for stdout_line in stdout_lines:
        yield stdout_line

    popen.stdout.close()
    return_code = popen.wait()
    if return_code != 0:
        raise subprocess.CalledProcessError(return_code, cmd)

if __name__ == '__main__':
    main()
```

## The imagr_config.plist

Now Imagr is opening up, it's time to make get our workflows ready. I've tried to keep things as simple as possible for our techs, so we use scripted included workflows. The basic idea is that we test if the local repo is present, and use that if it is. If not, we fall back to the repo that is on our web server. (Note: this isn't a full configuration, it is merely an example of the scenario described above)

``` xml imagr_config.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
   <dict>
      <key>workflows</key>
      <array>
         <dict>
            <key>components</key>
            <array>
               <dict>
                  <key>script</key>
                  <string>#!/usr/bin/python

import os

def main():
    if os.path.exists('/usr/local/imagr'):
        print 'ImagrIncludedWorkflow: sierra_local'
    else:
        print 'ImagrIncludedWorkflow: sierra_remote'

if __name__ == '__main__':
    main()</string>
                  <key>type</key>
                  <string>included_workflow</string>
               </dict>
            </array>
            <key>description</key>
            <string>Deploys a 10.12.2 image</string>
            <key>name</key>
            <string>sierra</string>
         </dict>
         <dict>
            <key>description</key>
            <string>Deploys 10.12.2 from local repo</string>
            <key>hidden</key>
            <true />
            <key>name</key>
            <string>sierra_local</string>
            <key>components</key>
            <array>
               <dict>
                  <key>type</key>
                  <string>image</string>
                  <key>url</key>
                  <string>file:///usr/local/imagr/masters/sierra.dmg</string>
               </dict>
               <dict>
                  <key>type</key>
                  <string>restart_action</string>
                  <key>action</key>
                  <string>none</string>
               </dict>
            </array>
         </dict>
         <dict>
            <key>description</key>
            <string>Deploys 10.12.2 from remote repo</string>
            <key>hidden</key>
            <true />
            <key>name</key>
            <string>sierra_remote</string>
            <key>components</key>
            <array>
               <dict>
                  <key>type</key>
                  <string>image</string>
                  <key>url</key>
                  <string>https://imagr.company.com/masters/sierra.dmg</string>
               </dict>
            </array>
         </dict>
      </array>
   </dict>
</plist>
```

## Things to note

When you see references to Reboot or Shutdown, this is referring to the machine Imagr is running on, not the volume you are imaging. Similarly, there is no way to know anything about the machine you are imaging (as it is just an external disk), so all [variable substitution](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#scripts) will be for the machine that Imagr is running on, not the disk you are restoring.