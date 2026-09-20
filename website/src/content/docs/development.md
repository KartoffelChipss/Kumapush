---
title: Development
description: Build and run the app, the relay and this website locally.
group: Project
groupOrder: 4
order: 1
---

KumaPush is one repository with three parts.

| Directory   | What it is                                                                  |
| ----------- | --------------------------------------------------------------------------- |
| `KumaPush/` | The iOS app, written in SwiftUI.                                            |
| `relay/`    | The relay, written in Go with Fiber and PostgreSQL.                         |
| `website/`  | This site, built with Astro. Docs are Markdown files in `src/content/docs`. |

Everything is licensed under [GPL-3.0](https://github.com/KartoffelChipss/Kumapush/blob/main/LICENSE).

## The relay

Requirements: Go, Docker and [Task](https://taskfile.dev).

```bash
cd relay
cp .env.example .env      # add your APNs key ID, team ID and bundle identifier
task db:up                # start PostgreSQL
task dev                  # run the relay on http://localhost:3000
```

`task dev` runs the relay in development mode, which uses the APNs sandbox. Run the tests with:

```bash
go test ./...
```

The `relay/bruno` directory contains a [Bruno](https://www.usebruno.com) collection for the device and webhook endpoints. To add a database migration, run `task db:migration -- add_something`.

### Releases

Publishing a GitHub release tagged `relay@x.y.z` builds the relay image for `linux/amd64` and `linux/arm64` and pushes it with the tags `x.y.z`, `x.y` and `x`.

## The app

Open `KumaPush/KumaPush.xcodeproj` in Xcode, select your team under **Signing & Capabilities** and run on a physical device. Push notifications don't work on the simulator. To point it at a local relay, use **Use custom relay** and enter its address.

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/KartoffelChipss/Kumapush). For larger changes, open an issue first so we can talk it through.
