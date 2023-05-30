+++
date = 2023-02-08T12:00:00Z
lastmod = 2023-02-08T12:00:00Z
title = "What's nagging you? Getting to the bottom of Managed Login Items"
categories = ["macos"]
+++

macOS 13 Ventura introduced Managed Login Items - a way to keep users informed about what LaunchAgents and LaunchDeamons are running on their devices and easily disable unwanted ones. We also _eventually_ got a [way manage these items on via MDM](https://developer.apple.com/documentation/devicemanagement/loginitemsmanageditems).

However, the notification users get when we either update the LaunchAgent or LaunchDaemon plist itself, **or** when we replace the binary the Login Item loads is next to useless.

![Notification Center popup stating Managed Login Items Added](/images/posts/2023-02-08/notification_managed_login_items_added.png)

This notification doesn't tell you, nor your users about what might have been updated. Chances are you've not just allow listed your custom software, but third party software too, which you probably have little control over how they behave. And of course, this only helps to further perpeutate comments from users such as "IT are installing more spyware on my computer!" even when we are innocent.

## So how can we find the culprit

Fortunately, this information is actually logged in Unified Logging, which can be viewed with this predicate:

```shell
sudo log show --last 24h --debug --info --predicate "process in {'smd', 'backgroundtaskmanagementd', 'BackgroundTaskManagementAgent'} and sender in { 'BackgroundTaskManagement','smd', 'backgroundtaskmanagementd', 'BackgroundTaskManagementAgent', 'ServiceManagement'}"
```

Which will output a whole ton of information about how the new background task management works. But if you want to just narrow down your offender:

```shell
sudo log show --last 24h --debug --info --predicate "process in {'smd', 'backgroundtaskmanagementd', 'BackgroundTaskManagementAgent'} and sender in { 'BackgroundTaskManagement','smd', 'backgroundtaskmanagementd', 'BackgroundTaskManagementAgent', 'ServiceManagement'} and eventMessage CONTAINS 'Posting managed'"
```

Which will output something like this, allowing you to identify the offender:

```shell
Timestamp                       Thread     Type        Activity             PID    TTL
2023-02-06 05:13:55.570878-0800 0x1013c04  Default     0x14e1a2c            669    0    BackgroundTaskManagementAgent: [com.apple.backgroundtaskmanagement:main] Posting managed item notification request, triggered by item: uuid=4B277990-365F-4B04-A79F-4426A36B5ED8, name=someService, type=managed legacy agent, disposition=[enabled, allowed, visible, notified], identifier=com.company.someService, url=file:///Users/graham_gilbert/Library/LaunchAgents/com.company.someService.plist
```
