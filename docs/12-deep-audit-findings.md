# Deep audit findings (2026-05-25)

Results of a thorough state survey of the Legion Go 2 on SteamOS 3.8.5, ~6 hours into the setup session. Captures discoveries that changed earlier decisions.

## Current state snapshot

| | |
|---|---|
| SteamOS | 3.8.5 (beta channel, build 20260520.100) |
| Kernel | 6.16.12-valve21-1-neptune-616 |
| CPU | AMD Ryzen Z2 Extreme (8C/16T) |
| GPU | Radeon 890M (RDNA 3.5) |
| RAM | 22 GB LPDDR5X |
| Storage | 1 TB NVMe (SKHynix HFS001TEM4X182N) |
| Display | 1920×1200 OLED, 144Hz VRR, HDR TrueBlack 1000 |
| amd_pstate driver | `active` mode (= EPP-based control) |

## Big finding: the CPU governor name is misleading

On AMD Z2 Extreme with **`amd_pstate=active`** (the kernel default on SteamOS), the real CPU performance knob is **EPP (Energy Performance Preference)**, not the legacy "governor" name.

Available EPP values:
- `performance` — maximum perf, all clocks high under load
- `balance_performance` — lean toward perf
- `default` — vendor default
- `balance_power` — lean toward saving (SteamOS idle default)
- `power` — maximum power saving

When the scaling governor name is `powersave`, EPP fully controls behavior. When the governor name is `performance`, EPP is forced to `performance`.

**What we previously did**: registered a systemd oneshot service to set governor=performance at boot.
**What we discovered**: steamos-manager actively reverts our setting whenever its profile changes. The service is overridden within seconds.

## SteamOS manages this — don't fight it

```
steamos-manager (system daemon)
       ↓
  decides EPP/governor/TDP based on:
       ↓
  ├── Active performance profile (Quick Access → Performance)
  ├── Battery vs AC state
  ├── GameMode IPC signal when a game launches
  └── Current gamemoded state (boost under load)
```

What this means in practice:

- **At idle / desktop**: EPP=`balance_power`, governor=`powersave`. Battery-friendly.
- **During gaming**: GameMode triggers → SteamOS bumps EPP to `performance`, TDP to your profile's target.
- **Profile switches via Steam UI / SimpleDeckyTDP**: SteamOS applies new EPP/TDP via D-Bus IPC.

This is correct behavior. The systemd service approach (which `docs/06-performance-tweaks.md` originally recommended) doesn't work because SteamOS overrides us.

**Action taken**: `cpu-governor-performance.service` is now **disabled** on the host. The file is kept at `/etc/systemd/system/` for reference but doesn't run on boot.

## The actual perf-control path now

1. **For one-tap profiles**: Steam button → Performance → pick Battery / Balanced / High Performance
2. **For fine-grained control**: SimpleDeckyTDP plugin → create profile → set TDP + GPU clock + EPP per-profile
3. **GameMode** automatically boosts perf for any actual Steam game launch

If you want to FORCE `EPP=performance` always (e.g. for testing): set up a path watcher service that re-applies on every file change. Fragile but works. Probably overkill.

## Other findings

### Firmware all up-to-date ✅

`fwupdmgr get-updates` reports:
- System Firmware: current
- Legion Controller (whole): v251208A — current
- Legion Controller (Left): v251204A — current
- Legion Controller (Right): v251204A — current
- UEFI CA, UEFI dbx: current

No firmware action needed. The "check for firmware updates" item from `docs/11-steamos-version-audit.md` is satisfied.

### Wi-Fi: currently 5GHz, hardware supports 6GHz

```
Connected to 9c:05:d6:64:98:42 (on wlan0)
    SSID: Wu-Tang LAN
    freq: 5180.0      <-- 5GHz Wi-Fi 6E band
    signal: -50 dBm   <-- excellent signal
    rx bitrate: 1729.6 MBit/s (Wi-Fi 6 PHY)
    tx bitrate: 2161.3 MBit/s
```

`iw phy0 channels` shows the Legion **does support 6GHz Wi-Fi 7** (Band 4 with channels at 6015 MHz and up). It's currently associated to a 5GHz access point.

To get full Wi-Fi 7:
- Confirm your router broadcasts a 6GHz SSID (usually a separate SSID or one with band steering)
- Connect Legion to that 6GHz SSID

Current 5GHz throughput is already excellent (~1.7-2.1 Gbps PHY rate, -50 dBm signal). Streaming bandwidth isn't the bottleneck — going to 6GHz is a marginal win.

### Audio loopback sink is normal

Default sink is `alsa_loopback_device.alsa_output.pci-0000_c2_00.6.analog-stereo` (Ryzen HD Audio Controller, analog stereo, wrapped in a loopback). This is normal PipeWire / SteamOS routing — the loopback exists so audio capture can multiplex from the main output. State=SUSPENDED is the idle state.

Not a problem. Speakers and headphones work normally through this sink.

### inputplumber udev errors (cosmetic only)

`/usr/lib/udev/rules.d/99-inputplumber-device-setup.rules:11` errors repeat in the journal:
```
Failed to write ATTR{...left_handle/imu_bypass_enable}="true", ignoring: No such file or directory
Failed to write ATTR{...right_handle/imu_bypass_enable}="true", ignoring: No such file or directory
Failed to write ATTR{...touchpad/vibration_enable}="false", ignoring: No such file or directory
```

inputplumber (SteamOS controller daemon) is trying to apply Steam Deck-shaped attributes to the Legion Go 2 controllers. The sysfs paths don't exist on Legion hardware. **Errors are non-fatal** — the controller works.

These will quiet down when the official Lenovo SteamOS edition ships (proper Legion Go 2 udev rules).

### Rootfs at 81% full is normal

```
/dev/nvme0n1p5  5.0G  3.5G  872M  81% /
```

SteamOS uses A/B partition sets where the rootfs is intentionally small (~5GB). Most data lives on separate partitions:
- `/usr` is on a different partition (6.2 GB)
- `/var` is on a different partition (2.4 GB used of separate partition)
- `/home` is on the big partition (7.4 GB used of 941 GB)

81% on rootfs is by design. Not a concern unless atomic updates start failing.

### GNOME idle delay extended to 30 min

Was: 5 min (300 sec). Now: 30 min (1800 sec). Stops Desktop Mode from sleeping aggressively when you're SSH'd in or actively configuring. Battery impact is small because the screen still sleeps after 5 min via gamescope.

```bash
gsettings set org.gnome.desktop.session idle-delay 1800
```

### steamos-manager error: GPU power profile missing

```
Error getting GPU power profile: Error opening sysfs file for reading No such file or directory
```

steamos-manager tries to read a GPU power profile file (`/sys/class/drm/card0/device/pp_power_profile_mode`) that **doesn't exist on Legion Go 2's RDNA 3.5 GPU**. This is a known gap — Valve's code assumes Steam Deck's RDNA 2 GPU which has that sysfs interface.

Error is non-fatal but shows up in journals constantly. Fix has to come from Valve.

## Updated action items (replaces / amends 11-steamos-version-audit.md)

### Stop doing (was unhelpful)
- ❌ Fighting steamos-manager via systemd governor service — now disabled
- ❌ Manually setting EPP via SSH — gets reverted within seconds

### Continue doing
- ✅ SimpleDeckyTDP profiles for fine-grained perf control
- ✅ Brightness fix plugin
- ✅ vm.swappiness=10, vfs_cache_pressure=50 (sysctl is persistent, SteamOS doesn't touch it)
- ✅ Native Quick Access → Performance for per-game profiles

### Worth doing
- Move to 6GHz Wi-Fi if your router supports it (marginal gain, ~30% throughput)
- Live with the inputplumber udev errors until official Lenovo SteamOS edition
- Check for firmware updates monthly via Settings → System (just to be safe)

## What ships with the official Lenovo SteamOS edition (June 2026)

When the Lenovo-supported edition releases, expect these fixes:
- Proper Legion Go 2 udev rules for inputplumber (no more spam errors)
- GPU power profile sysfs path that steamos-manager expects (no more daemon errors)
- Possible fan curve / TDP UI native integration
- Possibly the Legion Go 2 brightness bug fixed properly

At that point, do a clean reflash and re-evaluate which Decky plugins / scripts are still needed.

## Cross-reference

- `docs/06-performance-tweaks.md` — the original perf doc with sysctl + governor recommendations. **Note**: governor recommendation is now stale (per this audit), sysctl ones still good.
- `docs/11-steamos-version-audit.md` — initial version audit before this deep dive.
- `scripts/legion-steamos/cpu-governor-performance.service` — kept for historical reference but the service is disabled.
