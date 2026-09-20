---
title: How it works
description: What happens between a monitor going down and your phone buzzing.
group: Basics
groupOrder: 1
order: 2
---

KumaPush has three moving parts: the **app** on your phone, the **relay** on a server, and **APNs**, Apple's push service. Uptime Kuma only ever talks to the relay.

```text
Uptime Kuma ──POST /wh/<device-id>──▶ Relay ──HTTP/2 push──▶ APNs ──▶ iPhone
```

## Why a relay is needed

Apple only allows push notifications to reach an iPhone through APNs, and APNs only accepts a push from a server that can prove it belongs to the developer of that app. It proves this with a private signing key from the developer's Apple account.

That key must stay secret, so it can't be shipped inside the app, and it can't be handed to every Uptime Kuma installation. The relay is the one small service that holds it. It accepts a plain webhook from Uptime Kuma and turns it into a signed APNs request.

## Registration

The first time you tap **Get Started**:

1. The app requests notification permission and asks iOS to register for remote notifications. iOS returns a **device token**, an opaque hex string that identifies this app on this phone to APNs.
2. The app sends the device token to the relay with `POST /devices`.
3. The relay creates a device record with a random 14-character **device ID**, and generates a random **auth token**. It stores only a SHA-256 hash of the auth token and returns the plain token once.
4. The app keeps the device ID and auth token locally and builds your webhook URL: `<relay>/wh/<device-id>`.

The auth token is what lets the app read, update or delete its own device later. The webhook URL only needs the device ID.

## Delivering an alert

When a monitor changes state:

1. Uptime Kuma sends `POST /wh/<device-id>` to the relay with its usual JSON body, containing the monitor name and the heartbeat status and message.
2. The relay looks up the device ID. Unknown IDs get a `404`.
3. It builds the notification:
    - **Title:** `<monitor name> is up` or `<monitor name> is down`.
    - **Body:** the heartbeat message, for example `Request failed with status code 503`.
    - For a **down** alert on a device set to [Time Sensitive](/docs/notifications), the push is marked as time-sensitive.
    - Uptime Kuma's **Test** button sends no monitor, so the relay sends a notification titled `KumaPush` with the test message.
4. The relay sends the push to APNs over HTTP/2, signed with its key, addressed to your device token and the app's bundle identifier.
5. APNs delivers the notification to your iPhone. The relay records the time of the last successful delivery.

The relay does not store the notification content. It exists only for the length of the request.

## Keeping the device token fresh

APNs may hand out a new device token after a restore, reinstall or OS update. Every time the app opens it compares the current token with what the relay has and sends an update with `PATCH /devices/<id>` if they differ. Your webhook URL stays the same.

If the app is deleted, APNs eventually reports the token as invalid. The relay then removes the device and answers the webhook with `410 Gone`, so stale registrations clean themselves up.

## Where each piece runs

| Component | Runs on                                  | Source                                                                        |
| --------- | ---------------------------------------- | ----------------------------------------------------------------------------- |
| App       | Your iPhone                              | [`KumaPush/`](https://github.com/KartoffelChipss/Kumapush/tree/main/KumaPush) |
| Relay     | `relay.kumapush.com`, or your own server | [`relay/`](https://github.com/KartoffelChipss/Kumapush/tree/main/relay)       |
| APNs      | Apple                                    | n/a                                                                           |

For the relay's endpoints, see the [Relay API](/docs/api).
