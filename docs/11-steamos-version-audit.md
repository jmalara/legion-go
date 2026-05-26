# SteamOS version audit & remaining tweaks

What your specific SteamOS version (3.8.5 Beta) ships with natively for Legion Go 2, what we already covered via plugins/tweaks, and what's still worth checking.

## Your version

- **SteamOS 3.8.5** (Beta channel — confirmed by `VERSION_ID` in `/etc/os-release`)
- **Kernel**: Linux 6.16
- **KDE Plasma 6.4.3** on Wayland
- Updated AMD graphics driver
- Released as Beta in May 2026

## Native Legion Go 2 features in 3.8.5 (you already have these, just may not know)

| Feature | Where to find | Worth exploring |
|---|---|---|
| **System firmware updates** | Settings → System → System Updates | Check for Legion Go 2 controller firmware |
| **Controller firmware updates** | Settings → Controller | Run any pending updates |
| **Native RGB LED color** | Settings → Controller → LEDs | Overlaps with LegionGoRemapper — pick one |
| **Charge limiting** | Desktop Mode → System Settings → Power | Set to 80% for battery longevity if mostly docked |
| **Built-in TDP profiles** | Quick Access → Performance | Overlaps with SimpleDeckyTDP — both work |
| **SD card reliability fixes** | (automatic, no action) | Already applied |
| **Reduced controller input latency** | (automatic) | 5-10ms → 100-500μs |
| **VRR display support** | Settings → Display | 30-144Hz adaptive sync |

## Stuff we did via Decky that's now partially native

Run both, or pick one — they don't fight each other but configure overlapping things:

### RGB control: LegionGoRemapper vs native
- **Native (3.8.5)**: simple color picker, integrated into Quick Access
- **LegionGoRemapper**: more granular — per-button colors, animations, brightness
- **Recommendation**: try native first. Use LegionGoRemapper only if you want effects beyond solid colors.

### TDP control: SimpleDeckyTDP vs native
- **Native**: Performance profiles (Battery / Balanced / Custom) in Quick Access
- **SimpleDeckyTDP**: fine-grained TDP + GPU clock + governor per profile
- **Recommendation**: native Quick Access is faster for one-tap switching. SimpleDeckyTDP gives precision when you need it.

### What's NOT overlapping (keep these plugins)
- **Legion Go 2 Brightness Fix** — still needed, native brightness slider has the sleep-bug
- **MoonDeck** — no native Steam-to-Moonlight integration
- **SteamGridDB** — artwork
- **Controller Tools** — battery display

## Known bugs you might hit

These are SteamOS + Legion Go 2 issues without clean fixes:

1. **Brightness slider dies after sleep** — workaround: the Brightness Fix plugin
2. **Audio fuzzing on resume** — clears after ~30 sec; bumping TDP temporarily helps
3. **Sleep is aggressive** — handheld defaults assume battery use. Can be tuned in Settings → Power. We saw it sleep multiple times during this setup.
4. **RGB rings under joysticks** — native support is partial. Will improve with the official June 2026 SteamOS edition.

## Update channel: stay on Beta

You're on Beta channel (3.8.5). Don't switch to Stable (3.7.25) — that version **lacks all the Legion Go 2 support** we just covered. Stable will catch up when the official Lenovo SteamOS edition ships in June 2026.

To verify or switch channel:
- Settings → System → System Update Channel

## Action items for you

### Definitely do:

1. **Check for firmware updates**: Settings → System → System Updates → System & Controller. There may be Legion Go 2-specific firmware waiting.
2. **Set charge limit to 80%** if you mostly play docked: Desktop Mode → System Settings → Power → Battery limit (extends battery lifespan substantially)
3. **Run HDR Calibration** if not done: Settings → Display → HDR Calibration
4. **Pick RGB control side** (native OR LegionGoRemapper, not both fighting each other)

### Worth considering:

5. **Native TDP profile** — try the built-in slider before reaching for SimpleDeckyTDP
6. **Sleep timeout** — Settings → Power → Sleep & Idle. The handheld defaults are aggressive (we saw it sleep on us repeatedly).
7. **Tune audio on resume** — if the fuzzy audio bothers you, install the "Pause Games" Decky plugin with "Pause on Suspend" enabled

### Probably not worth doing:

- ❌ Switching to Stable channel (you'd lose Legion Go 2 support)
- ❌ Aggressive kernel cmdline tweaks (Valve has tuned these for Legion already in 3.8)
- ❌ Disabling SteamOS auto-updates (loses the firmware update path)

## What I'd revisit when Lenovo's official SteamOS edition ships (June 2026)

When the official Legion Go 2 SteamOS edition launches:
- Some Decky plugins may become unnecessary (especially LegionGoRemapper, possibly the Brightness Fix)
- The fan curve and TDP profiles will likely become first-class
- A fresh install onto official SteamOS may be cleaner than upgrading from the unofficial install we did
- Reassess all of this then; this repo's docs may need updates

Sources:
- [SteamOS 3.8.5 release notes (Tech Sportskeeda)](https://tech.sportskeeda.com/gaming-news/all-major-updates-steamos-3-8-5)
- [SteamOS 3.8 Legion Go 2 changes (Lenovo Gaming News)](https://gaming.lenovo.com/news/post/steamos-3-8-0-preview---legion-go-2-changes-ydGiqeOPmNxRLfa)
- [SteamOS 3.8.5 Beta on Gaming On Linux](https://www.gamingonlinux.com/2026/05/steamos-3-7-25-and-3-8-5-beta-released-bug-fixes-and-better-dgpu-video-memory-management/)
- [legion-go-tricks community repo](https://github.com/aarron-lee/legion-go-tricks)
- [SteamOS issue #2368 — brightness bug](https://github.com/ValveSoftware/SteamOS/issues/2368)
- [Gamescope issue #1987 — brightness after suspend on AMD Z2E](https://github.com/ValveSoftware/gamescope/issues/1987)
