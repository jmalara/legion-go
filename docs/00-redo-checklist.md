# Redo checklist — setting up a new Legion Go 2 from scratch

Ordered. Top to bottom. Each step links to the longer doc if you need detail.

## Phase 1 — SteamOS install (~30 min)

- [ ] Download recovery image: latest from https://steamdeck-images.steamos.cloud/steamdeck/ (look for newest `steamdeck-repair-*-3.x.x.img.zip`)
- [ ] Flash to USB-C drive (8GB+) with Balena Etcher. Ignore macOS "disk not readable" popups during flash.
- [ ] Power off Legion. Plug USB in. Hold **Volume Up + Power** for boot menu. Select USB.
- [ ] Click "Reimage Steam Deck" in installer. Wait 15-20 min. Wipes internal SSD.
- [ ] First boot: Wi-Fi, sign into Steam, let updates run.

Detail: [02-legion-steamos-setup.md](02-legion-steamos-setup.md)

## Phase 2 — Initial Legion config (~10 min)

In Desktop Mode (Steam button → Power → Switch to Desktop, then Konsole):

- [ ] `passwd` — set a deck user password
- [ ] `sudo systemctl enable --now sshd` — enable SSH for remote admin
- [ ] `ip addr show | grep "inet " | grep -v 127.0.0.1` — note your IP

## Phase 3 — Install Decky and plugins (~10 min)

In Konsole on the Legion:

- [ ] `curl -L https://decky.xyz/install | sh` — install Decky Loader
- [ ] Switch back to Game Mode. Open Quick Access → Decky → Store. Install:
  - [ ] SteamGridDB
  - [ ] Controller Tools
  - [ ] MoonDeck

From SSH or Konsole (these aren't in the official store):

- [ ] Run `scripts/legion-steamos/install-decky-plugin.sh` for each:
  ```bash
  sudo ./install-decky-plugin.sh https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos/releases/latest/download/legion-go2-brightness.zip
  sudo ./install-decky-plugin.sh https://github.com/aarron-lee/SimpleDeckyTDP/releases/latest/download/SimpleDeckyTDP.zip SimpleDeckyTDP
  sudo ./install-decky-plugin.sh https://github.com/aarron-lee/LegionGoRemapper/releases/latest/download/LegionGoRemapper.tar.gz LegionGoRemapper
  ```

Detail: [05-decky-plugins.md](05-decky-plugins.md)

## Phase 4 — System tweaks (~5 min)

From Konsole or SSH on the Legion:

- [ ] Clone or copy this repo to the Legion
- [ ] `sudo ./scripts/legion-steamos/apply-sysctl-tweaks.sh` — vm.swappiness=10, vfs_cache_pressure=50
- [ ] Install the governor service:
  ```bash
  sudo steamos-readonly disable
  sudo cp scripts/legion-steamos/cpu-governor-performance.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable --now cpu-governor-performance.service
  sudo steamos-readonly enable
  ```

Detail: [06-performance-tweaks.md](06-performance-tweaks.md)

## Phase 5 — Configure plugins in Game Mode (~10 min)

In Game Mode, Quick Access → Decky:

- [ ] **SimpleDeckyTDP**: create profiles
  - Battery: 10W, powersave
  - Balanced: 20W, performance
  - Performance: 28W, performance
  - Docked: 35W, performance
- [ ] **LegionGoRemapper**: map Legion L/R, set RGB profile, fan curve
- [ ] **SteamGridDB**: paste API key from https://www.steamgriddb.com/profile/preferences/api
- [ ] **MoonDeck**: add host (IP + Sunshine PIN pairing)
- [ ] **Legion Go 2 Brightness fix**: nothing to configure — just exists in Quick Access as a working slider

## Phase 6 — Display settings (in Game Mode)

- [ ] Steam → Settings → Display → **HDR Visuals = On**, **Allow HDR = On**
- [ ] Run **HDR Calibration**
- [ ] (Optional) Refresh rate stays at 144Hz; VRR handles dips

Detail: [04-moonlight-streaming-settings.md](04-moonlight-streaming-settings.md) for streaming-specific Moonlight client settings.

## Phase 7 — Wake-on-LAN + MoonDeck Buddy + MoonDeck pairing

- [ ] On the Windows host, verify WoL is enabled (see [08-wake-on-lan.md](08-wake-on-lan.md))
- [ ] On the Windows host, install MoonDeck Buddy via [`scripts/host-windows/install-moondeck-buddy.ps1`](../scripts/host-windows/install-moondeck-buddy.ps1) — required, Sunshine alone isn't enough
- [ ] On the Legion, run [`scripts/legion-steamos/moondeck-prefs.sh`](../scripts/legion-steamos/moondeck-prefs.sh) for sensible UI defaults
- [ ] In MoonDeck (Game Mode → Decky), add host. PIN-pair with both Buddy AND Sunshine (see [09-moondeck-preconfig.md](09-moondeck-preconfig.md))
- [ ] Enter host MAC into MoonDeck's WoL field
- [ ] Test: shut down host, launch a MoonDeck-enabled game on the Legion — host should wake and stream

## Phase 8 — Cleanup / hardening

- [ ] If you used a shared SSH key for setup, remove it: `sed -i '/<key-identifier>/d' ~/.ssh/authorized_keys`
- [ ] If SSH isn't needed long-term: `sudo systemctl disable --now sshd`
- [ ] Rotate `deck` password if any creds were used during setup

## Verification

After everything's applied, sanity check:

```bash
# CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor    # expect: performance
# Sysctl
sysctl vm.swappiness vm.vfs_cache_pressure                   # expect: 10, 50
# Decky service
systemctl is-active plugin_loader.service                    # expect: active
# Governor service
systemctl is-enabled cpu-governor-performance.service        # expect: enabled
# Brightness file (proves kernel sees the backlight)
ls -la /sys/class/backlight/amdgpu_bl0/brightness            # expect: -rw-rw-r-- root deck
```

If all four return what's expected, the Legion side is set up identically to before.

## Time estimate

- Fresh install: ~30 min
- Plugins + tweaks: ~25 min
- In Game Mode config: ~10 min
- **Total: ~65 min** (mostly waiting for downloads and SteamOS updates)
