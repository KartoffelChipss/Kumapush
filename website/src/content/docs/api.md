---
title: Relay API
description: HTTP endpoints exposed by the KumaPush relay.
group: Reference
groupOrder: 3
order: 1
---

The relay speaks JSON over HTTP. Errors always have this shape:

```json
{ "error": "device not found" }
```

## Authentication

Endpoints under `/devices/:id` require the device's auth token as a bearer token:

```text
Authorization: Bearer <auth-token>
```

A missing device and a wrong token are indistinguishable: both return `401 unauthorized`. `POST /devices` and the webhook endpoint need no authentication.

## Register a device

`POST /devices`

```json
{ "device_token": "<hex APNs device token>" }
```

The token must be an even-length hex string of 32 to 512 characters.

| Status | Meaning                                                                                                                          |
| ------ | -------------------------------------------------------------------------------------------------------------------------------- |
| `201`  | A new device was created.                                                                                                        |
| `200`  | The token was already registered. The existing device is returned with a **new** auth token, and the previous one stops working. |
| `400`  | Invalid body or device token.                                                                                                    |
| `429`  | Too many registrations.                                                                                                          |

The response contains the device and its auth token, which is shown only here:

```json
{
    "id": "V1StGXR8_Z5jdH",
    "device_token": "…",
    "last_successful_notification": "",
    "date_added": "2026-09-20T12:00:00Z",
    "down_notification_level": "normal",
    "auth_token": "…"
}
```

## Get a device

`GET /devices/:id` returns the device object shown above, without `auth_token`.

## Update a device

`PATCH /devices/:id`

```json
{
    "device_token": "<new hex APNs device token>",
    "down_notification_level": "time-sensitive"
}
```

Both fields are optional, but at least one is required. `down_notification_level` must be `normal` or `time-sensitive`. Returns the updated device.

| Status | Meaning                                        |
| ------ | ---------------------------------------------- |
| `200`  | Updated.                                       |
| `400`  | Nothing to update, or an invalid value.        |
| `401`  | Missing or wrong auth token.                   |
| `409`  | Another device already uses that device token. |

## Delete a device

`DELETE /devices/:id` removes the device and returns `204`. Its webhook URL stops working immediately.

## Webhook

`POST /wh/:deviceId`

This is the endpoint Uptime Kuma calls. It accepts Uptime Kuma's standard webhook JSON:

```json
{
    "heartbeat": { "status": 0, "msg": "Request failed with status code 503" },
    "monitor": { "name": "API" },
    "msg": "[API] [🔴 Down] Request failed with status code 503"
}
```

A `heartbeat.status` of `1` is treated as **up**, anything else as **down**. If `heartbeat` or `monitor` is missing, as in Uptime Kuma's **Test** button, the request is treated as a test and `msg` becomes the notification body.

| Status | Meaning                                                                    |
| ------ | -------------------------------------------------------------------------- |
| `200`  | The notification was handed to APNs.                                       |
| `400`  | Invalid body.                                                              |
| `404`  | Unknown device ID.                                                         |
| `410`  | APNs reported the device token as no longer valid. The device was removed. |
| `429`  | Rate limit exceeded.                                                       |
| `502`  | APNs rejected the notification.                                            |
| `500`  | The relay couldn't send the notification.                                  |

## Health

`GET /health` returns `200 {"status":"ok"}` if the database is reachable and `503` otherwise.

## Rate limits

Limits use a sliding window and are applied per client IP.

| Endpoint                              | Limit                           |
| ------------------------------------- | ------------------------------- |
| `POST /devices`                       | 5 per minute and 30 per hour    |
| `POST /wh/:deviceId`                  | 60 per minute per IP and device |
| `POST /wh/:deviceId`, failed requests | 10 per minute per IP            |

Exceeding a limit returns `429 too many requests`. The failed-request limit makes guessing device IDs impractical.
