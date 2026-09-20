---
title: Configuration
description: Environment variables and defaults for the KumaPush relay.
group: Self-hosting
groupOrder: 2
order: 2
---

The relay is configured entirely through environment variables. With the provided Compose file, set them in `relay/.env`.

## APNs

| Variable                | Required | Description                                                                                                               |
| ----------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------- |
| `APNS_AUTH_KEY_PATH`    | Yes      | Path to the `.p8` APNs auth key inside the container. The Compose file sets this to `/run/secrets/apns_auth_key` for you. |
| `APNS_KEY_ID`           | Yes      | Key ID of the APNs auth key.                                                                                              |
| `APNS_TEAM_ID`          | Yes      | Your Apple Developer Team ID.                                                                                             |
| `APP_BUNDLE_IDENTIFIER` | Yes      | Bundle identifier of the app. It's used as the APNs topic.                                                                |
| `ENV`                   | No       | Set to `development` to use the APNs sandbox instead of production.                                                       |

The relay exits at startup if any of the required APNs variables is missing.

## Database

| Variable            | Description          |
| ------------------- | -------------------- |
| `DATABASE_HOST`     | PostgreSQL host.     |
| `DATABASE_PORT`     | PostgreSQL port.     |
| `DATABASE_USER`     | PostgreSQL user.     |
| `DATABASE_PASSWORD` | PostgreSQL password. |
| `DATABASE_NAME`     | Database name.       |

The Compose file sets all of these for its bundled PostgreSQL 16. You only provide `POSTGRES_PASSWORD`. Migrations are applied on startup.

## Server

| Variable          | Default           | Description                                                                     |
| ----------------- | ----------------- | ------------------------------------------------------------------------------- |
| `PORT`            | `4321`            | Port the relay listens on inside the container.                                 |
| `BEHIND_PROXY`    | `false`           | Set to `true` when running behind a reverse proxy.                              |
| `PROXY_HEADER`    | `X-Forwarded-For` | Header the proxy uses to pass the client IP.                                    |
| `TRUSTED_PROXIES` | none              | Comma-separated proxy addresses to trust, in addition to `127.0.0.1` and `::1`. |

Client IPs drive the [rate limits](/docs/api#rate-limits). Without `BEHIND_PROXY`, every request behind a reverse proxy appears to come from the proxy's address and shares a single limit.

## Compose-only variables

These are read by `docker-compose.yml`, not by the relay itself.

| Variable             | Default         | Description                                            |
| -------------------- | --------------- | ------------------------------------------------------ |
| `POSTGRES_PASSWORD`  | none (required) | Password for the bundled PostgreSQL database.          |
| `RELAY_PORT`         | `4321`          | Host port the relay is published on.                   |
| `APNS_AUTH_KEY_FILE` | `./authkey.p8`  | Host path of the `.p8` key mounted into the container. |

## Health check

`GET /health` returns `{"status":"ok"}` when the database is reachable and `503` otherwise. The container image also ships a `healthcheck` command, which the Docker `HEALTHCHECK` uses, so `docker ps` shows whether the relay is healthy.

## Limits

Request bodies are limited to 64 KB. The relay logs one line per request (status, method, route, latency and client IP) but never request bodies or notification content.
