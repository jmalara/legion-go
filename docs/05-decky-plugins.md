# Decky Loader + plugins installed

## Decky Loader install

```bash
curl -L https://decky.xyz/install | sh
```

Self-elevates with sudo. Installs to `~/homebrew/`. Systemd service `plugin_loader.service` set to start on boot. Version installed: **v3.2.3**.

Verify:
```bash
systemctl status plugin_loader.service
```

## Plugins installed

| Plugin | Source | Purpose |
|---|---|---|
| Legion Go 2 Brightness fix CachyOS | [GitHub](https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos) — not in store | Bypasses broken Steam brightness slider |
| SimpleDeckyTDP | [GitHub](https://github.com/aarron-lee/SimpleDeckyTDP) | TDP / GPU freq / governor per profile |
| LegionGoRemapper | [GitHub](https://github.com/aarron-lee/LegionGoRemapper) — v0.3.0 has Legion Go 2 support | Button remapping, RGB, fan curve |
| SteamGridDB | Decky store | Pretty artwork for non-Steam games |
| Controller Tools | Decky store | Controller battery / charging UI |
| MoonDeck | Decky store | Stream Steam games via Moonlight without manual Add Non-Steam Game |

## Installing plugins outside the official store

The Legion Go 2 Brightness fix isn't in Decky's official store. For these, download the release zip from GitHub and extract to `~/homebrew/plugins/<plugin-name>/`:

```bash
cd /tmp
curl -sL -o plugin.zip https://github.com/.../releases/download/vX.Y/plugin.zip
unzip plugin.zip
PLUGIN_DIR=$(find . -name plugin.json -exec dirname {} \; | head -1)
sudo cp -r "$PLUGIN_DIR" /home/deck/homebrew/plugins/
sudo chown -R root:root /home/deck/homebrew/plugins/<plugin-name>
sudo systemctl restart plugin_loader.service
```

Plugins from the store (SteamGridDB, MoonDeck, Controller Tools): install via Quick Access → Decky icon → Store → Install button.

## SimpleDeckyTDP profile recommendations

Based on Z2 Extreme benchmarks:

| Profile | TDP | CPU governor | GPU freq | Use case |
|---|---|---|---|---|
| Battery saver | 10W | powersave | auto | Indie / 2D / old games — 4+ hour battery |
| Balanced | 20W | performance | auto | Typical AAA at medium |
| Performance | 28W | performance | auto | AAA at high @ 1200p |
| Docked / plugged in | 35W | performance | auto / max | Max settings |

Z2 Extreme can boost to 45W for ~10s. Sustained is 35W (max for SimpleDeckyTDP slider). Set CPU governor per-profile if you want it to track the use case; otherwise our system-wide `performance` setting will apply (see [`docs/06-performance-tweaks.md`](06-performance-tweaks.md)).

## LegionGoRemapper notes

- v0.3.0 has **initial** Legion Go 2 support — not all features work
- Worth setting up: Legion L/R button mapping (long-press, short-press), RGB profiles
- Fan curve control is incomplete on Legion Go 2 (vs Legion Go original)

## SteamGridDB API key

Optional. Without a key, the plugin works but rate-limits aggressively. Get a free key at https://www.steamgriddb.com/profile/preferences/api — paste into the plugin settings.

## Decky React error #31

If Decky's Quick Access panel shows "An error occurred while rendering this content" (minified React error #31), it's because a Steam UI update broke Decky's component injection. Workarounds:

1. Restart Steam: Steam menu → Exit Steam, then relaunch
2. Restart Decky: `sudo systemctl restart plugin_loader.service`
3. Disable plugins one at a time to find a culprit
4. Wait for Decky's next patch (they chase Steam UI changes)

Decky v3.2.3 supposedly fixed the most common cause. If the error reappears after a Steam update, repeat the workaround.
