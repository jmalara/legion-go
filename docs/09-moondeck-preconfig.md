# MoonDeck pre-configuration

MoonDeck lets you launch Steam games directly via Moonlight without manually adding them as Non-Steam games. The setup needs to be done from the Legion (in Game Mode → Decky → MoonDeck panel), but here's the reference for what to put in.

## What MoonDeck needs

| Field | Value | Notes |
|---|---|---|
| Host name | Whatever you want | Display label only |
| Host IP | `192.168.1.157` | Your Windows host |
| Sunshine port | `47989` | Default Sunshine HTTPS port |
| HTTPS port | `47984` | Default Sunshine config port |
| MAC address | `50-EB-F6-CE-2B-EB` | For WoL — MoonDeck can wake the host |
| Pairing PIN | Generated on first connect | One-time setup |

## Steps in the Decky MoonDeck panel

1. Quick Access → Decky icon → **MoonDeck**
2. **Add host**
3. Enter the host's IP (192.168.1.157) — MoonDeck discovers Sunshine via the default ports
4. MoonDeck shows a **PIN** to enter on the host side
5. On Windows: open `https://localhost:47990` (Sunshine web UI) → **PIN** tab → enter the PIN → Submit
6. Pair completes
7. In MoonDeck settings, enable:
   - **Wake on LAN** → enter MAC `50-EB-F6-CE-2B-EB` (auto-wakes host before stream)
   - **Quit game when host disconnects**: yes
   - **Resolution / FPS overrides**: 1920×1200 @ 120 (matches Legion native)

## How it works after pairing

1. Browse your Steam library on the Legion as normal
2. For games marked as MoonDeck-enabled (per-game toggle), launching them:
   - Sends WoL packet to host (if asleep)
   - Connects to Sunshine
   - Launches the game on the host via Sunshine's `cmd` mechanism
   - Streams it back to the Legion via Moonlight
   - When you exit, host gets the signal and quits the game
3. Quit Moonlight client = Steam library on Legion shows the game as not-running again

## Why it's better than manual Add Non-Steam Game

- No `flatpak run` shenanigans for Moonlight client
- Maintains Steam game library structure on Legion
- Achievements, playtime, screenshots all stay tied to the actual Steam entry
- Friend list / Steam Chat work as expected
- WoL integrated — host doesn't need to stay on

## Things to set on the host side once paired

In Sunshine web UI (`https://localhost:47990` from your Windows browser):

- **Pin tab**: confirm the MoonDeck pairing shows as a client
- **Apps**: confirm `Steam Big Picture`, `EA Games`, `Epic Games`, and `Desktop` are listed
- **Configuration → Audio/Video**: confirm encoder = NVENC, codec preference includes AV1
- **Configuration → Advanced → Internal Stream Port**: leave at default

## Caveats

- First pair sometimes fails — restart Sunshine service, restart Decky, retry
- After a Windows update, the pairing can break (Sunshine certificates regenerate) — re-pair
- WoL through MoonDeck depends on the host actually being properly configured for WoL — see [`docs/08-wake-on-lan.md`](08-wake-on-lan.md)
