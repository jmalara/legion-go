# Legion Go 2 + SteamOS + Moonlight streaming setup

Personal notes and scripts for running stock SteamOS on a Lenovo Legion Go 2, streaming games from a Windows 11 host (RTX 5090) over Wi-Fi 7 via Sunshine + Moonlight.

Set up over one long session on 2026-05-25. Stuff worth remembering before the next time something breaks.

## TL;DR setup

- **Legion Go 2**: stock SteamOS 3.9.0 (the May 11 2026 recovery image, see [docs/02](docs/02-legion-steamos-setup.md))
- **Host**: Windows 11, Sunshine + MTT Virtual Display Driver
- **Network**: Wi-Fi 7 to Legion, wired ethernet to host
- **Streaming**: Moonlight Flatpak on Legion → Sunshine on host. AV1 codec, 1920×1200 @ 120Hz, ~100 Mbps

## Read order

- 🚀 **[Redo checklist](docs/00-redo-checklist.md)** — if you're setting up a new Legion Go 2 from scratch, start here. Ordered, ~65 min total.
- [Overview & the SteamOS vs Bazzite choice](docs/01-overview.md) — why we made the decisions we did
- [Legion Go 2 SteamOS install](docs/02-legion-steamos-setup.md)
- [Windows host: Sunshine + VDD](docs/03-windows-host-sunshine.md)
- [Moonlight client settings](docs/04-moonlight-streaming-settings.md)
- [Decky plugins worth installing](docs/05-decky-plugins.md)
- [Performance tweaks (sysctl, governor)](docs/06-performance-tweaks.md)
- [Known issues & workarounds](docs/07-known-issues.md)
- [Wake-on-LAN setup](docs/08-wake-on-lan.md) — wake the host from the Legion before streaming
- [MoonDeck pre-config](docs/09-moondeck-preconfig.md) — pairing the Legion's Decky plugin with Sunshine
- [Auto-swap primary display on stream](docs/10-display-autoswap.md) — make games launch on VDD, not the 4K monitors
- [SteamOS version audit](docs/11-steamos-version-audit.md) — what 3.8.5 already does natively, what overlaps with plugins, action items

## Scripts

Re-runnable. Read before running — most need root.

- [`scripts/legion-steamos/legion-bright.sh`](scripts/legion-steamos/legion-bright.sh) — CLI brightness control, bypasses broken Steam slider
- [`scripts/legion-steamos/apply-sysctl-tweaks.sh`](scripts/legion-steamos/apply-sysctl-tweaks.sh) — vm tweaks
- [`scripts/legion-steamos/cpu-governor-performance.service`](scripts/legion-steamos/cpu-governor-performance.service) — systemd unit, sets governor on boot
- [`scripts/host-windows/vdd_settings.xml`](scripts/host-windows/vdd_settings.xml) — working VDD config with 1920×1200 as default
- [`scripts/host-windows/sunshine.conf.example`](scripts/host-windows/sunshine.conf.example) — working Sunshine config (sanitized)
- [`scripts/wake-host.sh`](scripts/wake-host.sh) — portable WoL sender (Mac + Legion)

## Honest take

Stock SteamOS on the Legion Go 2 works but isn't great. The Lenovo-supported SteamOS edition ships ~June 2026 — until then, **Bazzite is the cleaner path** for Legion Go 2 hardware. If you find yourself fighting more hardware quirks, re-flash to Bazzite and most issues evaporate.

See [docs/01-overview.md](docs/01-overview.md) for the full tradeoff discussion.
