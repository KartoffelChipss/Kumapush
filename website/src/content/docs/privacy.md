---
title: Privacy & security
description: What the relay stores, what it doesn't, and how to keep your webhook URL safe.
group: Reference
groupOrder: 3
order: 2
---

KumaPush is built to know as little about you as possible. There are no accounts, no email addresses and no analytics in the app or the relay.

## What the relay stores

For each registered device the relay keeps one row:

| Field                                       | Purpose                                                             |
| ------------------------------------------- | ------------------------------------------------------------------- |
| Device ID                                   | A random 14-character ID used in your webhook URL.                  |
| Device token                                | The APNs token for your app on your phone. Needed to push to it.    |
| Auth token hash                             | A SHA-256 hash of your auth token. The plain token is never stored. |
| Down notification level                     | `normal` or `time-sensitive`.                                       |
| Date added and last successful notification | Timestamps.                                                         |

## What the relay doesn't store

Notification content, meaning monitor names, status and messages, is used to build the push and then discarded. It isn't written to the database or to the logs. Request logs contain only the status, method, route, latency and client IP.

That said, content does pass through the relay, and it passes through Apple's APNs on its way to your phone. If that matters for your monitors' names, [host your own relay](/docs/self-hosting).

## Keep your webhook URL secret

The webhook endpoint requires no authentication: knowing the device ID is enough to send a notification to your phone. Device IDs are 14 random characters, and the relay limits failed webhook requests per IP, which makes guessing impractical. The consequences of a leak are limited to someone sending you unwanted notifications.

If your URL leaks, open the app and tap **Unregister Device**, then register again. You'll get a new device ID and need to update the URL in Uptime Kuma.

## Auth tokens

The app stores its auth token locally and uses it to read, update or delete its own device. Tokens are 32 random bytes and hashed before storage. Registering an already-known device token issues a new auth token and invalidates the old one.

## Transport

The public relay is served over HTTPS. The app asks for confirmation before connecting to a custom relay over plain `http://`, because tokens would be visible to anyone on the network. Use HTTPS for any relay you host.

## Reporting a vulnerability

Please open a private security advisory on [GitHub](https://github.com/KartoffelChipss/Kumapush/security/advisories) instead of a public issue.
