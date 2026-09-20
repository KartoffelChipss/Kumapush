---
title: Getting started
description: Install KumaPush, register your device and connect Uptime Kuma.
group: Basics
groupOrder: 1
order: 1
---

Setup takes about two minutes and needs nothing beyond the app and an Uptime Kuma instance you can log in to.

## 1. Register your device

1. Open KumaPush and tap **Get Started**.
2. Allow notifications when iOS asks. Without this permission the app cannot receive any alert.
3. The app asks iOS for a device token and registers it with the relay. This normally takes a second or two.

When it succeeds you'll see **You're all set!** together with your **device ID** and step-by-step instructions containing your personal webhook URL.

> [!TIP]
> By default the app uses the public relay at `https://relay.kumapush.com`. To use a relay you host yourself, tap **Use custom relay** before registering. See [Self-hosting](/docs/self-hosting).

## 2. Add a webhook in Uptime Kuma

1. In Uptime Kuma, go to **Settings → Notifications** and choose **Setup Notification**.
2. Set **Notification Type** to **Webhook**.
3. Set **Post URL** to the URL shown in the app. It looks like this:

    ```text
    https://relay.kumapush.com/wh/V1StGXR8_Z5jdH
    ```

4. Set **Request Body** to **Preset - application/json**.
5. Save the notification.

> [!IMPORTANT]
> Treat the webhook URL like a password. Anyone who has it can send notifications to your phone. See [Privacy & security](/docs/privacy).

## 3. Send a test

Press **Test** in Uptime Kuma's notification dialog. A notification titled **KumaPush** should arrive within a few seconds.

Then tick **Default enabled** or attach the notification to individual monitors, and you're done. From now on you'll get:

- `<monitor name> is down` with the failure message when a monitor goes down.
- `<monitor name> is up` when it recovers.

## Changing settings later

Open the app to see your device ID and webhook URL again, switch [notification levels](/docs/notifications), or **Unregister Device** to remove your phone from the relay. Unregistering deletes the device on the relay, so the webhook URL stops working.

If something doesn't arrive, see [Troubleshooting](/docs/troubleshooting).
