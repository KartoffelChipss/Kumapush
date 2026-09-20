---
title: Troubleshooting
description: Fixes for the most common problems with registration and missing notifications.
group: Reference
groupOrder: 3
order: 3
---

## Nothing arrives when I press Test

1. **Check the response.** Uptime Kuma shows the webhook's HTTP status. Compare it with the [status codes](/docs/api#webhook):
    - `404`: the device ID in the URL is wrong or the device was unregistered. Copy the URL from the app again.
    - `410`: APNs said your device token is invalid and the relay removed the device. Open the app to register again.
    - `429`: you're sending too fast, or failing too often. Wait a minute.
    - `502`: APNs rejected the push. On a self-hosted relay this usually means the key, team ID or bundle identifier doesn't match the app. See below.
2. **Check iOS settings.** Under **Settings → Notifications → KumaPush**, make sure notifications are allowed.
3. **Check Focus.** A Focus mode may be hiding non-urgent notifications. Consider the [Time Sensitive level](/docs/notifications) for down alerts.

## "Could not register" in the app

- **Notification permission was denied.** Enable it under **Settings → Notifications → KumaPush** and try again.
- **Registering on a simulator.** APNs isn't available on the iOS Simulator for device tokens, so use a physical device.
- **Custom relay unreachable.** Open `https://your-relay/health` in a browser. It should return `{"status":"ok"}`.
- **Rate limited.** Registration is limited to 5 per minute and 30 per hour per IP.

## Self-hosted relay returns 502 or nothing arrives

APNs only accepts a push if all of these agree:

- The **key** (`.p8`), **Key ID** and **Team ID** belong to the team that signed the app.
- `APP_BUNDLE_IDENTIFIER` equals the app's bundle identifier exactly.
- The **environment** matches. Apps run from Xcode need `ENV=development` (sandbox), while TestFlight and App Store builds need production (the default).

Check the relay logs for the `reason` APNs returned:

```bash
docker compose logs relay
```

Common reasons are `BadDeviceToken` (environment mismatch or a stale token), `InvalidProviderToken` (wrong key or team), and `DeviceTokenNotForTopic` (wrong bundle identifier).

## The relay can't read the APNs key

The container runs as a non-root user, so the key file must be readable by it:

```bash
chmod 644 authkey.p8
```

## Rate limiting blocks everyone behind my proxy

If every request appears to come from the same address, the relay isn't reading client IPs from your proxy. Set `BEHIND_PROXY=true` and add the proxy's address as seen from the container to `TRUSTED_PROXIES`. See [Configuration](/docs/configuration#server).

## I reinstalled the app and the webhook stopped working

If iOS issues the same device token, registering again keeps your device ID and the webhook URL stays the same. If the token changed, you get a new device ID. Copy the new URL from the app into Uptime Kuma.
