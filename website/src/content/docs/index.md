---
title: Introduction
description: KumaPush delivers Uptime Kuma alerts to your iPhone as native push notifications.
---

KumaPush is an iOS app and a small open-source relay that together deliver [Uptime Kuma](https://github.com/louislam/uptime-kuma) alerts to your iPhone as native push notifications.

Uptime Kuma can already tell a webhook when a monitor goes up or down. KumaPush gives that webhook somewhere to go: you register your phone, get a personal webhook URL, paste it into Uptime Kuma, and every status change shows up on your lock screen.

## What you get

- **Real push notifications** delivered through Apple's Push Notification service (APNs). They arrive even when the app is closed.
- **A personal webhook URL** you paste into Uptime Kuma. There is nothing to install next to your Kuma server.
- **Time Sensitive downtime alerts**, if you want them, so "down" notifications can break through Focus.
- **No account.** The app identifies your phone with a random device ID and a private token, nothing more.
- **An open-source, self-hostable relay** written in Go, backed by PostgreSQL.

## The pieces

| Piece            | What it does                                                                                                     |
| ---------------- | ---------------------------------------------------------------------------------------------------------------- |
| **KumaPush app** | Registers your phone with a relay, shows your webhook URL and lets you change notification settings.             |
| **Relay**        | Receives webhooks from Uptime Kuma and forwards them to APNs. The default relay is `https://relay.kumapush.com`. |
| **Uptime Kuma**  | Your monitoring. It calls the relay's webhook URL when a monitor changes state.                                  |
| **APNs**         | Apple's delivery network. It is the only way to push to an iPhone.                                               |

## Where to go next

1. [Getting started](/docs/getting-started): install the app and connect Uptime Kuma in a few minutes.
2. [How it works](/docs/how-it-works): what happens between a monitor going down and your phone buzzing.
3. [Self-hosting](/docs/self-hosting): run your own relay.

> [!NOTE]
> KumaPush requires iOS 27 or later, which is the app's current deployment target.
