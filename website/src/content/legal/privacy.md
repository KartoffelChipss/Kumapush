---
title: Privacy Policy
description: How the official KumaPush relay handles your data when you use the KumaPush app with it.
---

**Last updated: 20 September 2026**

This Privacy Policy explains what personal data is processed when you use the KumaPush iOS app with the **official relay** at `https://relay.kumapush.com`, who processes it, why, and what your rights are.

## Scope: the official relay only

> [!IMPORTANT]
> This policy applies **only** when you use the KumaPush app with the official relay, `https://relay.kumapush.com`. It does **not** apply if you use the app with a custom or self-hosted relay, or with a relay run by anyone else.

KumaPush is open source, and the app lets you enter the address of a relay you host yourself. In that case the operator of that relay, which may be you, decides what happens to your data and is responsible for it. We have no access to a relay we don't run, and this policy says nothing about it. If you use a custom relay, ask its operator for their privacy information.

The app itself contains no analytics, advertising or tracking code and talks only to the relay you chose and to Apple's push service. That holds whichever relay you use.

## What we process

KumaPush has no accounts. We don't ask for your name, email address, phone number or location, and we don't collect any of them.

### When you register (Get Started)

The app asks iOS for permission to send notifications. If you allow it, iOS gives the app a **device token** that identifies the app on your phone to Apple's push service, and the app sends it to the relay. The relay stores one record per device:

| Data                                        | Purpose                                                                                                                   |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Device ID                                   | A random 14-character ID we generate. It is the last part of your webhook URL.                                            |
| Device token                                | The Apple Push Notification service (APNs) token. Needed to push to your phone.                                           |
| Auth token hash                             | A SHA-256 hash of the secret token your app uses to manage its own record. The token itself is never stored on the relay. |
| Down notification level                     | Your choice of `normal` or `time-sensitive`.                                                                              |
| Date added and last successful notification | Two timestamps. They show when the record was created and when a push last succeeded.                                     |

This record isn't linked to your name or any account. It is still personal data under the GDPR, because the device token is an identifier for your device.

### When an alert is delivered

Your Uptime Kuma server sends a webhook to your personal URL. It contains the **monitor name**, the **status** (up or down) and the **message** of the heartbeat, or the text of a test notification. The relay turns this into a push notification and hands it to Apple's servers, addressed to your device token.

**We do not store notification content.** It is held in memory only for the length of the request and is never written to the database or to the logs. It does pass through the relay and through Apple on its way to you. Monitor names and messages are chosen by you, so please don't put secrets or sensitive personal information into them. The [Terms of Service](/terms) ask the same.

### Server logs and rate limiting

For every request the relay writes one log line containing the **HTTP status, method, route pattern, response time and client IP address**. The route is the route pattern (`/wh/:deviceId`), not the actual URL, so device IDs don't appear in it. Requests to `/health` aren't logged. If Apple rejects a push, we also log Apple's status code and reason, but never the notification.

For webhook requests the IP address is that of your Uptime Kuma server. For registration and app requests it is your phone's IP address. IP addresses are personal data.

To limit abuse, the relay counts requests per IP address (and per IP address and device ID). These counters are held in memory only and are discarded as their time windows expire. See [rate limits](/docs/api#rate-limits).

### What stays on your phone

The app stores your device ID and the relay address in its local settings, and your auth token in the iOS Keychain, set so that it stays on this device and is not carried over to another one. Nothing else is stored, and none of it is sent anywhere except to the relay.

## Why we process it, and on what legal basis

| Purpose                                                                                 | Legal basis under the GDPR                                             |
| --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Registering your device and delivering your alerts                                      | Performance of the service you asked for, Art. 6(1)(b)                 |
| Server logs, rate limiting and abuse prevention, keeping the service secure and working | Our legitimate interest in a secure and reliable service, Art. 6(1)(f) |

You are not required by law to provide any of this data. Without it, the service can't work.

We don't use your data for advertising, profiling or analytics. We don't sell it. We don't make automated decisions about you.

## Who receives your data

- **Apple.** Push notifications can only reach an iPhone through the Apple Push Notification service. The relay sends Apple your device token and the notification content, and Apple delivers it. Apple processes this under its own privacy policy, and its servers may be outside your country. See [apple.com/legal/privacy](https://www.apple.com/legal/privacy/).
- **Our server provider, IONOS SE.** We run the relay ourselves on a virtual server that we rent from IONOS in Germany, so the data we store stays in Germany. IONOS only provides the infrastructure and doesn't operate the relay or use the data for its own purposes.
- **Authorities or courts**, if we are legally required to disclose data. Because we hold so little, there is little we could give.

Nobody else receives your data.

## How long we keep it

| Data                       | Kept until                                                                                                                                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Device record              | You tap **Unregister Device** in the app, we delete it on request, or Apple reports your device token as invalid and the relay removes the record on the next alert. |
| Notification content       | Never stored.                                                                                                                                                        |
| Server logs (including IP) | No longer than 30 days, then deleted.                                                                                                                                |
| Rate-limit counters        | Minutes. Held in memory only.                                                                                                                                        |

Deleting the app **doesn't** immediately delete your record, because the relay isn't told. It is removed when an alert is next sent to a token that Apple no longer accepts. To have your record removed right away, tap **Unregister Device** in the app before deleting it, or [contact us](mailto:contact@kumapush.com).

## Your rights

Under the GDPR you have the right to:

- **access** the data we hold about you,
- have inaccurate data **rectified**,
- have your data **erased**,
- **restrict** its processing,
- receive it in a portable format, and
- **object** to processing based on our legitimate interests.

You can erase your record yourself at any time with **Unregister Device** in the app. For any other request, contact us using the details above.

Because we don't know who you are, we can't tell your record from anyone else's by name. To exercise a right we may need you to identify your record, for example by giving us your device ID, which the app shows on its main screen.

## Security

The official relay is served over HTTPS. Auth tokens are 32 random bytes and stored only as a SHA-256 hash. Device IDs are random and rate limiting makes guessing them impractical. Our [Privacy & security](/docs/privacy) page describes the details. Treat your webhook URL like a password. Anyone who has it can send notifications to your phone.

No system is perfectly secure. If you find a vulnerability, please report it through a private [GitHub security advisory](https://github.com/KartoffelChipss/Kumapush/security/advisories) instead of a public issue.

## Children

KumaPush is a tool for people who run monitoring servers. It isn't directed at children, and we don't knowingly process data from children under 16. If you believe a child has used the service, contact us and we will delete their record.

## This website

This policy covers the app and the official relay. For completeness: the KumaPush website is a static site hosted on GitHub Pages. We don't run analytics, and the site sets no cookies and loads no third-party scripts, fonts or trackers. GitHub, as the host, may process technical data such as your IP address when you visit, under [GitHub's privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement).

## Changes to this policy

We may update this policy, for example if the relay changes what it processes. The date at the top shows when it last changed. The full history is public in the [project's repository](https://github.com/KartoffelChipss/Kumapush/commits/main/website/src/content/legal/privacy.md). If a change significantly affects how your data is handled, we'll say so in the release notes for the app or relay.
