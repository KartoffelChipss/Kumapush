---
title: Notification levels
description: Choose how downtime alerts are delivered on your iPhone.
group: Basics
groupOrder: 1
order: 3
---

KumaPush lets you decide how **down** alerts are delivered. **Up** alerts and Uptime Kuma's test notification are always delivered normally.

Open the app and use the **Down notifications** picker on the registered screen.

## Normal

Down alerts are delivered like any other notification. They respect your Focus modes, Do Not Disturb and notification summary settings.

## Time Sensitive

Down alerts are marked as time-sensitive. iOS delivers them immediately and lets them **break through Focus and Do Not Disturb**. They do **not** override the silent switch.

Use this if a missed outage would cost you something and you'd rather be woken up.

> [!NOTE]
> Time Sensitive delivery can still be turned off per app in iOS under **Settings → Notifications → KumaPush**, and a Focus can be configured to block it.

## How it's applied

The level is stored on the relay together with your device, not just in the app. When a down webhook arrives, the relay adds the `time-sensitive` interruption level to the push. Changing the setting in the app sends `PATCH /devices/<id>` with `down_notification_level` set to `normal` or `time-sensitive`. It takes effect for the next alert.
