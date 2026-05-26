# MoonDeck setup — host (Buddy) + client (Decky plugin)

MoonDeck has **two halves** that both need to be configured:

1. **MoonDeck Buddy** — small companion app on the Windows host (port 59999). Sunshine alone isn't enough.
2. **MoonDeck Decky plugin** — on the Legion. Pairs with both Sunshine AND Buddy.

## Host: MoonDeck Buddy install

Already installed at `C:\Tools\MoonDeckBuddy\MoonDeckBuddy-1.9.2-win64\bin\MoonDeckBuddy.exe`.

- **Autostart**: registered in `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` as `"MoonDeckBuddy"`. Starts on next login.
- **Port**: 59999 (confirmed listening)
- **Reinstall script**: [`scripts/host-windows/install-moondeck-buddy.ps1`](../scripts/host-windows/install-moondeck-buddy.ps1)

The installer-style `.exe` from GitHub hangs on a UAC/wizard prompt when run from SSH — we use the portable `.7z` instead.

## Client: MoonDeck Decky plugin (Legion)

Plugin installed already. UI preferences pre-set via [`scripts/legion-steamos/moondeck-prefs.sh`](../scripts/legion-steamos/moondeck-prefs.sh).

Settings file: `~/.config/moondeck/settings.json`.

## Pairing — must be interactive

Both halves use PIN-based pairing. This part you do once, in Game Mode:

1. On the Legion in Game Mode, open **Quick Access → Decky → MoonDeck**
2. **Add new host** — enter:
   - Host name: anything (e.g. "JermsPC")
   - Address: `192.168.1.157`
3. MoonDeck shows a PIN — note it
4. On the Windows host, open the **MoonDeck Buddy tray icon** → enter the PIN there
5. Repeat for Sunshine: same host page → **Pair Sunshine** → use the PIN tab in `https://localhost:47990` (Sunshine web UI) on host
6. MoonDeck stores the host UUID in `hostSettings` in `settings.json`

## Host MAC for WoL

`50-EB-F6-CE-2B-EB` — paste this into MoonDeck's per-host **Wake-on-LAN** field after pairing.

## Schema reference

For if you ever need to manually edit `~/.config/moondeck/settings.json`:

```typescript
HostSettings {
    address: string         // "192.168.1.157"
    manualAddress: boolean  // true if user-entered
    infoPort: number        // Sunshine info port, default 47989
    buddyPort: number       // MoonDeck Buddy port, default 59999
    hostName: string        // display name
    mac: string             // for WoL, "50-EB-F6-CE-2B-EB"
}
```

Schema lives in the plugin source at `~/homebrew/plugins/moondeck/python/lib/cli/settings.py`.

## Default ports

| Service | Port | Protocol |
|---|---|---|
| Sunshine HTTPS (control) | 47984 | TCP |
| Sunshine info | 47989 | TCP |
| Sunshine web UI | 47990 | TCP (HTTPS) |
| MoonDeck Buddy | 59999 | TCP |
| GameStream / RTSP | 48010 | TCP |
| Audio / video stream | 47998-48000 | UDP |

## Things to set on the host side once paired

In Sunshine web UI (`https://localhost:47990`):

- **Pin tab**: confirm MoonDeck pairing landed
- **Apps**: Desktop, Steam Big Picture, EA Games, Epic Games (all pre-configured)
- **Configuration → Audio/Video**: NVENC encoder, AV1 in codec list

## Things that don't pre-config cleanly

- **Host pairing entry** — requires fresh PIN exchange every time (paired UUID + cert is per-session)
- **Per-game launch profiles** in Sunshine — depend on which games you have installed, set via web UI

## Caveats / known issues

- First pair sometimes fails — restart Sunshine + Buddy + Decky service, retry
- After a Windows update, certs can rotate and pairing breaks — re-pair
- Buddy tray icon may not appear if it was launched from a non-interactive session (SSH) — log out + log in to get it back in the system tray
- MoonDeck Buddy is portable — uninstalling = deleting `C:\Tools\MoonDeckBuddy` and removing the HKCU Run entry
