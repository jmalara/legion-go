# Overview & the SteamOS vs Bazzite choice

## What this setup is for

Use the Legion Go 2 as a low-power handheld client that streams demanding games from the desktop (RTX 5090, Windows 11) over the local network. Wi-Fi 7 on the Legion, wired ethernet on the host.

## OS choice

Three paths exist for a Legion Go 2:

| Path | When to pick it |
|---|---|
| **Stock SteamOS** (what we ran) | Want Steam Deck UX, fine with workarounds for Legion-specific quirks |
| **Bazzite** | Want SteamOS-like UX with Legion Go 2 hardware properly supported |
| **Lenovo's official SteamOS edition** | Ships ~June 2026. Best of both. |

This repo documents the stock SteamOS path because that's what we set up.

## What works on stock SteamOS

- Boot, install, Steam library, game launching
- Moonlight streaming via Flatpak
- Decky Loader + most plugins
- AMD GPU drivers + Vulkan
- Wi-Fi (no Bluetooth complaints either)
- Display at native res once manually set

## What's broken or annoying on stock SteamOS

- **Brightness slider** dies after sleep/wake — needs the [Legion Go 2 Brightness Fix Decky plugin](https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos)
- **No native TDP slider** — needs [SimpleDeckyTDP](https://github.com/aarron-lee/SimpleDeckyTDP)
- **Lenovo buttons (Legion L/R, M1/2/3) unmapped** — partial fix via [LegionGoRemapper](https://github.com/aarron-lee/LegionGoRemapper) v0.3.0+
- **Fan curve** sits on whatever firmware default — no control
- **RGB rings** under joysticks not controllable on SteamOS
- **HHD (Handheld Daemon)** officially refuses to install on stock SteamOS (`Installing Handheld Daemon on SteamOS is not canon.`)
- **Immutable rootfs** fights any `pacman` install; have to `steamos-readonly disable` first

## What works the same as Bazzite

- Steam UI, gamescope, mangohud
- Decky Loader plugin ecosystem
- Moonlight streaming
- HDR (Gamescope handles it; both OS use the same gamescope build)

## The decision tree, in one paragraph

Pick **stock SteamOS** if you want the official-Valve UX and don't mind a handful of community-plugin workarounds. Pick **Bazzite** if you want Legion Go 2 hardware features (fan, TDP, controllers, RGB) to just work without manual tweaking. Pick the **official Lenovo SteamOS edition** when it ships in June 2026 — that's when both paths converge.

## Hardware in this setup

- **Legion Go 2**: Ryzen Z2 Extreme APU, Radeon 890M iGPU, 22 GB RAM, 8.8" OLED 1920×1200 @ 144Hz, HDR TrueBlack 1000
- **Host PC** (Windows 11): RTX 5090, dual 4K ROG STRIX monitors, Wi-Fi 7 router
- **Network**: 192.168.1.x LAN, both devices on it
