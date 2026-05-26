# Per-game launch options & runtime env vars cheat sheet

Stuff to know when tweaking individual games via Steam's "Launch Options" field (right-click game → Properties → General → Launch Options). Add before `%command%`.

## Format

```
ENV_VAR=value gamemoderun %command% --your-game-arg
```

Multiple vars: just space-separated.

## Performance / latency

| Option | When to use |
|---|---|
| `gamemoderun %command%` | **Always.** Wraps with Feral GameMode for scheduler boost + I/O priority. Smooths frame pacing. |
| `MANGOHUD=1 %command%` | Force MangoHud overlay even if global is off. |
| `ENABLE_LAYER_MESA_ANTI_LAG=1 %command%` | AMD Anti-Lag, reduces input latency. Per-game (some games don't like it). |
| `RADV_PERFTEST=gpl %command%` | Enable Graphics Pipeline Library — faster shader compile. Default in modern Mesa anyway. |

## Upscaling / scaling

| Option | When to use |
|---|---|
| `WINE_FULLSCREEN_FSR=1 %command%` | Enable FSR upscaling for any Vulkan/DXVK/VKD3D game. Renders below native, upscales. |
| `WINE_FULLSCREEN_FSR_STRENGTH=2 %command%` | FSR sharpness. `0`=max sharp, `5`=min. Default `2` is AMD's recommended. |
| `gamescope -w 1920 -h 1200 -W 1920 -H 1200 -f -F fsr %command%` | Force FSR via gamescope wrapper (sharper than WINE_FULLSCREEN_FSR for some games). |

## Compatibility fixes

| Option | When to use |
|---|---|
| `PROTON_NO_ESYNC=1 %command%` | Disable esync — some old games hate it. Try if a game crashes on launch. |
| `PROTON_NO_FSYNC=1 %command%` | Disable fsync — same idea, fsync is newer than esync. |
| `radv_zero_vram=false %command%` | Set in `~/.drirc` for global, or as env. Can fix stutters in demanding games (Cyberpunk, RDR2). |
| `PROTON_USE_WINED3D=1 %command%` | Use WineD3D instead of DXVK. Slow, but unblocks some DX9/10 games. |
| `WINEDEBUG=-all %command%` | Suppress Wine debug output. Tiny perf gain. |

## Debugging / logging

| Option | When to use |
|---|---|
| `PROTON_LOG=1 %command%` | Logs to `~/steam-XXXXX.log` — for diagnosing crashes. |
| `DXVK_HUD=fps,frametimes %command%` | Built-in DXVK overlay (alternative to MangoHud). |
| `VKD3D_DEBUG=warn %command%` | VKD3D-Proton warnings (DX12 games). |

## Per-game Proton version

Right-click game → **Properties** → **Compatibility** → **Force the use of a specific Steam Play compatibility tool** → pick:

- **Proton Experimental** — Valve's main Proton, latest features
- **Proton Hotfix** — Valve's stable + critical fixes
- **GE-Proton10-34** (installed in this repo's setup) — community fork with extra patches:
  - Media foundation (better video playback in games)
  - Raw input improvements
  - AMD-specific optimizations
  - "protonfixes" applies per-game tweaks automatically

Try GE-Proton if a game doesn't work or has issues with stock Proton.

## MangoHud

Config installed at `~/.config/MangoHud/MangoHud.conf` (see setup notes in `12-deep-audit-findings.md`).

Toggle in-game:
- **Shift+F12** — show/hide overlay
- **Shift+F11** — start/stop performance log (saves to `~/mangohud-logs/`)

Per-game force with launch option:
```
MANGOHUD=1 %command%
```

Reading the overlay (left to right):
- `FPS X | Y ms` — current FPS / frametime
- `GPU X% Y°C ZW` — utilization, temp, power
- `CPU X% Y°C ZW` — same
- `RAM X / Y MB` — memory
- `BAT X% (Yh Zm)` — battery + estimated time
- `FAN X RPM` — fan speed

## Recommended baseline for AAA games on Legion Go 2

```
gamemoderun MANGOHUD=1 WINE_FULLSCREEN_FSR=1 %command%
```

This: enables GameMode (perf scheduler), shows the perf overlay, allows the game to use FSR upscaling.

## When streaming via Sunshine/Moonlight (host PC games)

These env vars apply on the **host PC**, not the Legion. For your RTX 5090 box, NVIDIA-specific options:
- Reflex enabled per-game in NVIDIA Control Panel
- DLSS via game settings
- Frame Generation if supported

For the Legion as a client, the only relevant tweaks are in the Moonlight client settings, not launch options.

## Cross-reference

- [`docs/05-decky-plugins.md`](05-decky-plugins.md) — for Decky-specific per-game tweaks (PowerTools, MangoHud config plugin if installed)
- [`docs/12-deep-audit-findings.md`](12-deep-audit-findings.md) — why SteamOS-level env vars don't always persist
