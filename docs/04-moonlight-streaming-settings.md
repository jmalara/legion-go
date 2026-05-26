# Moonlight client streaming settings

## Recommended settings for Legion Go 2 client

Hardware backdrop: Legion's panel is 1920×1200 OLED @ 144Hz with VRR 30-144. Host is 5090 with 9th-gen NVENC, Wi-Fi 7 to client.

| Setting | Value | Why |
|---|---|---|
| Resolution | **1920 × 1200** | Match the native panel — no scaling |
| Frame rate | **120 FPS** | Sweet spot for frame pacing. 144 only if game can lock 144 end-to-end |
| Bitrate | **100 Mbps** (push to 120-150 on stable Wi-Fi 7) | 5090 encodes plenty; network is the limit |
| Video codec | **AV1** (HEVC fallback) | 5090 + 890M both have AV1 hw codec; ~40% better quality at same bitrate vs H.264 |
| HDR | **On** | Both panel and 5090 support it |
| V-Sync | **On** | With VRR panel, V-Sync ON doesn't add latency. Required to unlock the Frame Pacing dropdown. |
| Frame Pacing | **Balanced** | Lower latency than "Smoothest" without the artifacts of "Closest to refresh rate" |
| Optimize for game | **On** | Tells Sunshine to set game-friendly host settings |

## Why V-Sync is ON, not OFF

Counterintuitive but correct: on a VRR-capable display like the Legion Go 2's OLED, V-Sync in Moonlight doesn't impose the latency cost it would on a fixed-refresh display. The panel adapts to the frame timing. V-Sync ON + Frame Pacing Balanced gives you smoothness without tearing.

V-Sync OFF only matters on fixed-refresh displays. Yours isn't one.

## What NOT to enable

- ❌ **"Force RGB Full Range"** unless you've calibrated → easy way to crush blacks
- ❌ **Highest frame rate (144)** unless games actually hit 144 — frame pacing gets choppy when host FPS dips below target
- ❌ **VSync on the host game** — let G-Sync/VRR handle it

## Mac Moonlight (for testing or daily use from the Mac)

Match what your Mac panel is. If you're testing the stream from the Mac:
- Resolution: pick a real one like 1920×1200 or 2560×1440 — don't leave it on "Auto" or weird defaults. We hit a bug where Mac Moonlight requested an undefined resolution and Sunshine fell back to 800×600.
- Everything else: same as Legion settings

## Network notes

- **Host on wired ethernet** matters more than client Wi-Fi version. Plug the host PC into the router.
- **Wi-Fi 7 on the Legion**: confirm you're on 6 GHz band (Wi-Fi 7 advantage), not 5 GHz fallback. Check in SteamOS Wi-Fi settings.
- **QoS** in Sunshine web UI: enabled. Router QoS for Sunshine's TCP/UDP ports (47984-48010) if your router supports it.
- **Disable Wi-Fi power saving** on the Legion. We verified it was already off (good default on SteamOS).

## Performance overlay (in-stream stats)

Inside an active Moonlight stream:
- Mac client: `Ctrl+Alt+Shift+S` → shows stats overlay
- Legion: same shortcut, or via the Moonlight UI control

What to look for:
- **Decoder latency** < 8 ms (your 5090 will be well under)
- **Network latency** < 10 ms (LAN, Wi-Fi 7)
- **Frame loss** < 0.1% — if higher, bitrate too aggressive for your link
- **Drop frames** > 0.5% = network or decoder issue

## MoonDeck (Decky plugin) — important workflow

`MoonDeck` lets you stream Steam library games directly via Moonlight without manually adding them as Non-Steam games. The plugin:
1. Pairs with your Sunshine host
2. When you launch a Steam game from your Legion library, MoonDeck intercepts → launches the game on the host PC → streams it back via Moonlight

Setup in Decky panel:
1. Open MoonDeck
2. Add host: pair using the PIN method (Sunshine UI on host → Add Client → enter PIN)
3. Set host's Sunshine address (IP : port, default `192.168.1.x:47989`)
4. Enable per-game

This is the single biggest win for streaming workflow — eliminates the manual Non-Steam Game shuffle.
