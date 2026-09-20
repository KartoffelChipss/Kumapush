---
title: Self-hosting the relay
description: Run your own KumaPush relay with Docker Compose.
group: Self-hosting
groupOrder: 2
order: 1
---

The relay is a Go service backed by PostgreSQL. You can run your own and point the app at it with **Use custom relay**.

> [!WARNING]
> **A self-hosted relay needs your own build of the app.** APNs only accepts pushes signed with a key from the same Apple Developer team that signed the app. The official KumaPush build is signed by the project's team, so your relay's key can't push to it. To self-host you need to build and sign KumaPush yourself, as described below.

## What you need

- A server with **Docker** and Docker Compose, reachable over **HTTPS** from both your phone and your Uptime Kuma server.
- An **Apple Developer Program** membership.
- **Xcode**, to build and install the app on your device.

## 1. Set up Apple credentials

In the Apple Developer portal, under **Certificates, Identifiers & Profiles**:

1. Create an **App ID** (a bundle identifier of your choice, such as `com.example.kumapush`) with the **Push Notifications** capability. The app also uses the **Time Sensitive Notifications** capability.
2. Under **Keys**, create a key with **Apple Push Notifications service (APNs)** enabled and download the `.p8` file. Apple lets you download it only once.
3. Note the **Key ID** (shown next to the key) and your **Team ID** (shown in your membership details).

## 2. Build the app with your team

1. Clone the repository and open `KumaPush/KumaPush.xcodeproj` in Xcode.
2. In the target's **Signing & Capabilities**, select your team and change the bundle identifier to the App ID from step 1. The repository is configured for the maintainer's team and bundle identifier.
3. Build and run it on your iPhone.

> [!NOTE]
> Apps installed straight from Xcode use the **APNs sandbox**. Apps distributed through TestFlight or the App Store use **production**. The relay talks to production by default. Set `ENV=development` to use the sandbox. See [Configuration](/docs/configuration).

## 3. Start the relay

The `relay/` directory contains a Compose file that runs the relay and PostgreSQL together.

```bash
cd relay
cp .env.example .env
```

Edit `.env` and fill in the required values:

```bash
POSTGRES_PASSWORD=choose-a-long-random-password
APNS_KEY_ID=ABC123DEFG
APNS_TEAM_ID=XYZ987WXYZ
APP_BUNDLE_IDENTIFIER=com.example.kumapush
```

Put your APNs key next to the Compose file as `authkey.p8` (or point `APNS_AUTH_KEY_FILE` at it) and make sure it's readable by the container's non-root user:

```bash
cp ~/Downloads/AuthKey_ABC123DEFG.p8 ./authkey.p8
chmod 644 authkey.p8
```

Start everything:

```bash
docker compose up -d --build
```

The relay listens on port `4321` (change the published port with `RELAY_PORT`). Database migrations run automatically on startup. Verify that it's up:

```bash
curl http://localhost:4321/health
```

```json
{ "status": "ok" }
```

## 4. Put it behind HTTPS

The app warns before connecting to a plain `http://` relay, because your device token and auth token would travel unencrypted. Terminate TLS with a reverse proxy, for example Caddy:

```text
relay.example.com {
    reverse_proxy 127.0.0.1:4321
}
```

Behind a proxy, tell the relay to trust it so that rate limiting sees real client IPs instead of the proxy's:

```bash
BEHIND_PROXY=true
# The proxy's address as seen from inside the relay container,
# e.g. the Docker network gateway.
TRUSTED_PROXIES=172.18.0.1
```

## 5. Connect the app

In the app, tap **Use custom relay**, enter `https://relay.example.com` and tap **Continue**. Then follow [Getting started](/docs/getting-started) from step 2. Your webhook URL will point at your relay.

## Updating

Pull the latest changes and rebuild:

```bash
git pull
docker compose up -d --build
```

Tagged relay releases (`relay@x.y.z`) also publish multi-architecture Docker images for `linux/amd64` and `linux/arm64`. Pending migrations are applied when the new version starts.
