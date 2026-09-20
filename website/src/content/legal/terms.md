---
title: Terms of Service
description: The terms for using the KumaPush app with the official relay.
---

**Last updated: 20 September 2026**

These Terms of Service ("Terms") govern your use of the KumaPush iOS app together with the **official relay** at `https://relay.kumapush.com` (the "Service"). By registering your device with the Service, you agree to them. If you don't agree, please don't use the Service.

## 1. Scope: the official relay only

> [!IMPORTANT]
> These Terms apply **only** to the KumaPush app used with the official relay, `https://relay.kumapush.com`. They do **not** apply if you use the app with a custom or self-hosted relay, or with a relay run by anyone else.

KumaPush is open source. The app lets you enter the address of a relay you host yourself, and you are free to run your own. If you do, these Terms have no effect on that relay or on your use of it. The operator of that relay, which may be you, is solely responsible for it, and we have no control over it and no responsibility for it.

Our [Privacy Policy](/privacy) is limited to the official relay in the same way.

## 2. What the Service does

KumaPush forwards alerts from your own [Uptime Kuma](https://github.com/louislam/uptime-kuma) installation to your iPhone. You register your device with the relay and get a personal webhook URL. When Uptime Kuma calls that URL, the relay converts the alert into a push notification and sends it to your device through Apple's Push Notification service (APNs). See [How it works](/docs/how-it-works) for details.

KumaPush is not affiliated with or endorsed by Uptime Kuma or Apple.

## 3. Using the Service

**Free of charge.** The Service is free. There are no accounts, subscriptions or in-app purchases.

**Eligibility.** You must be old enough to enter into a binding agreement in your country, or have the permission of a parent or guardian to do so.

**Your webhook URL.** Your device ID is part of your webhook URL, and anyone who has the URL can send notifications to your phone. Keep it secret. If it leaks, tap **Unregister Device** in the app and register again to get a new one. You are responsible for anything sent through a URL you have shared.

**Your content.** Monitor names and messages come from your Uptime Kuma server and pass through the relay and Apple's servers. You are responsible for what you send. Don't send secrets, credentials, or sensitive personal information in them, and don't send anything unlawful.

## 4. Acceptable use

You agree not to:

- use the Service for anything unlawful, or to send spam, harassing, misleading or harmful notifications to yourself or anyone else;
- send notifications to devices that you don't own or aren't authorized to notify, or try to find or guess other people's device IDs or auth tokens;
- circumvent, probe or overload the Service, including its [rate limits](/docs/api#rate-limits), or run load tests or automated scans against it without our written permission;
- attempt to gain unauthorized access to the Service, its data or its infrastructure, or disrupt it for others;
- use the Service in a way that could get us blocked or penalised by Apple, or that violates Apple's terms for APNs; or
- register devices in bulk or resell or redistribute access to the Service.

If you want to test the security of the Service, please do so responsibly and report what you find through a private [GitHub security advisory](https://github.com/KartoffelChipss/Kumapush/security/advisories).

## 5. No guarantee of delivery, and not for critical alerting

Notifications depend on many things that we don't control: your Uptime Kuma server, the network, Apple's push service, iOS, and your notification, Focus and battery settings. **The Service is provided on a best-effort basis. Notifications can be delayed, dropped or duplicated, and we don't promise that any alert will arrive.**

Don't rely on KumaPush as the only way of learning about an outage. In particular, don't use it for anything where a missed or late alert could endanger life, health or safety, or cause significant loss. Use a redundant alerting channel for anything that matters.

## 6. Availability and changes

We may change, limit, suspend or discontinue the Service or any part of it at any time, for example for maintenance, security, cost, or legal reasons. There is no service-level agreement. Where it is reasonably possible, we will announce a planned shutdown in advance, for example in the project's release notes or on the website.

Because KumaPush is open source, you can always run your own relay and build the app for it. See [Self-hosting](/docs/self-hosting).

## 7. Suspension and ending your use

**You** can stop at any time by tapping **Unregister Device** in the app, which deletes your record from the relay, and then deleting the app.

**We** may suspend or remove a device, or block an IP address, if we reasonably believe you have broken these Terms, are abusing or endangering the Service, or if we're legally required to. We also remove records automatically when Apple reports a device token as invalid.

## 8. Privacy

How we handle personal data is described in the [Privacy Policy](/privacy), which forms part of these Terms.

## 9. Open source and the App Store

The source code of the app, the relay and this website is licensed under the [GNU General Public License v3.0](https://github.com/KartoffelChipss/Kumapush/blob/main/LICENSE). **These Terms don't limit the rights the GPL gives you to that code.** They govern only your use of the hosted official Service.

If you download the app from the App Store, Apple's own terms for app downloads also apply between you and Apple. Apple isn't a party to these Terms, isn't responsible for the Service, and has no obligation to provide support for it.

## 10. Disclaimer of warranties

To the fullest extent permitted by law, the Service is provided **"as is" and "as available"**, without warranties of any kind, whether express or implied, including any warranty of availability, reliability, accuracy, fitness for a particular purpose or non-infringement.

## 11. Limitation of liability

The Service is provided free of charge. To the fullest extent permitted by law, we are not liable for any loss or damage arising from your use of, or inability to use, the Service. This includes missed, late or duplicate notifications, downtime that went unnoticed, lost data, and lost profits or business.

Nothing in these Terms limits or excludes liability that can't be limited or excluded by law. This includes liability for intent or gross negligence, for injury to life, body or health, under mandatory product liability rules, and any other liability that mandatory law says can't be waived. If you are a consumer, the mandatory consumer protection rules of the country where you live continue to apply.

## 12. Changes to these Terms

We may update these Terms, for example when the Service changes. The date at the top shows when they last changed, and the full history is public in the [project's repository](https://github.com/KartoffelChipss/Kumapush/commits/main/website/src/content/legal/terms.md). If a change is significant, we will say so in the release notes for the app or relay. If you keep using the Service after a change takes effect, you accept the updated Terms. If you don't accept them, stop using the Service and unregister your device.

## 13. General

**Governing law.** These Terms are governed by the laws of the Federal Republic of Germany, without its conflict-of-law rules. If you are a consumer, this doesn't take away the protection of mandatory provisions of the law of the country where you live, and you may also bring proceedings in the courts of that country.

**Severability.** If part of these Terms is found invalid or unenforceable, the rest stays in force, and the invalid part is replaced by a valid one that comes as close as possible to its intent.

**No waiver.** If we don't enforce a right, that doesn't mean we've given it up.

**Entire agreement.** These Terms and the Privacy Policy are the whole agreement between you and us about the Service. They replace any earlier agreement on the same subject.

## 14. Contact

For questions about these Terms, [contact us](mailto:contact@kumapush.com). Bug reports and feature requests go on [GitHub](https://github.com/KartoffelChipss/Kumapush/issues). Security issues should be reported privately, as described above.
