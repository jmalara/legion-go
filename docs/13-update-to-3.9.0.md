# Update from SteamOS 3.8.5 (beta) to 3.9.0 (main)

Done 2026-05-25, ~6 hours into setup session.

## How we got here

We tried switching to `preview` channel first, but `atomupd-manager check` reported "No update available" because the current preview build was the same 3.8.5 we were already on. The 3.9.0 build (20260520.1000) was actually staged on the `main` channel (developer/staging branch).

Channel ordering from most-tested to most-bleeding-edge:
```
stable → rc → beta → bc → preview → pc → main
```

Switched to `main`, applied 3.9.0, rebooted. ~5 min total (1 min download, ~3 min reboot).

```bash
sudo steamos-select-branch main           # now: holo-select-branch (renamed in 3.9)
sudo atomupd-manager update 20260520.1000
sudo reboot
```

## What changed in 3.9.0

| | 3.8.5 (beta) | 3.9.0 (main) |
|---|---|---|
| Kernel | 6.16.12-valve21-1-neptune-616 | **6.18.32-valve1-1-neptune-618** |
| Tools naming | `steamos-readonly`, `steamos-select-branch` | **renamed to `holo-readonly`, `holo-select-branch`** (shims keep old names working) |
| Variant | steamdeck | steamdeck (same) |
| Sysctl persistence | survives | **reverted (atomic update wiped /etc/sysctl.d/)** |

The rename to `holo-*` reflects SteamOS expanding beyond Steam Deck — it's now meant to be the OS for Steam Machine, third-party handhelds, etc. The "steamdeck" variant identifier is still used but expect that to shift too.

## Things that still survived the update (good)

- ✅ Decky Loader (all 6 plugins still listed: Brightness Fix, SimpleDeckyTDP, LegionGoRemapper, SteamGridDB, Controller Tools, MoonDeck)
- ✅ SSH access (`~/.ssh/authorized_keys` intact)
- ✅ Wi-Fi auto-reconnected (same SSID, even better signal: -47 dBm vs -50 dBm)
- ✅ Brightness sysfs permissions unchanged
- ✅ Battery state preserved

## Things that reverted (need re-applying after major updates)

- ❌ **`/etc/sysctl.d/99-legion-perf.conf` wiped** — vm.swappiness reset to 60, vfs_cache_pressure reset to 100
- ❌ `cpu-governor-performance.service` — already disabled by us pre-update, irrelevant
- ❌ GNOME idle-delay reset to 5 min (need to re-apply with `gsettings set org.gnome.desktop.session idle-delay 1800`)

**Re-applying after the update**: `scripts/legion-steamos/apply-sysctl-tweaks.sh` ran successfully. Verified sysctl values back to 10/50.

This is a meta-finding: **after every major SteamOS update, re-run the sysctl + idle-delay scripts**. The `/etc` partition gets rebuilt by atomic updates.

## What DIDN'T get fixed in 3.9.0 (still need workarounds)

Still happening in journal after the update:

1. **Inputplumber udev errors**: 115 occurrences in 5 minutes — Valve still hasn't shipped the Legion Go 2-specific udev rules
2. **`steamos-manager: Error getting GPU power profile`**: 12 in 5 min — still looking for Steam Deck sysfs paths that don't exist on RDNA 3.5

These are cosmetic (don't break anything) but the noise in journals is the same as on 3.8.5.

## NEW issues on 3.9.0

**KDE PowerDevil I2C permission errors** appeared (didn't exist on 3.8.5):

```
org_kde_powerdevil[4246]: Error EACCES(-13): Permission denied opening /dev/i2c-10
...same for /dev/i2c-11 through /dev/i2c-19
```

PowerDevil (KDE's power management daemon) is trying to read I2C devices for battery/power info but doesn't have permission. Cosmetic. Likely fixed in a future point release.

## Action items for the user to verify in Game Mode

These need hands-on testing on the device:

1. **Brightness slider after sleep** — was broken on 3.8.5 (needed the Decky plugin). Test: sleep → wake → try slider. If it works natively, you can disable the Brightness Fix plugin.

2. **Legion L / R button native mapping** — were unmapped on 3.8.5 (needed LegionGoRemapper). Press them in Game Mode — do they open Steam menu / Quick Access natively?

3. **HDR Calibration** — 3.9.0 has improved HDR. Re-run Settings → Display → HDR Calibration.

4. **Performance profiles** — Steam's built-in performance selector may have new Legion-aware options.

## Should you have done this?

**Yes if**:
- You want the latest kernel (6.18 vs 6.16 — better Z2 Extreme support)
- You want to test native Legion Go 2 fixes as they land
- You don't mind re-applying tweaks after future updates

**No if**:
- You wanted a fully stable, no-surprises experience — main is a developer channel, future updates could be more breaking than this one
- The 5-minute disruption is unwelcome

For now you're on the bleeding edge of the path to the official Lenovo SteamOS edition (June 2026). Switch back to `beta` if main feels too unstable in coming weeks.

## Switching back if needed

```bash
sudo holo-select-branch beta   # was: steamos-select-branch
# Next system update will roll you back to whatever's current on beta
```

(Note: rolling backward across major versions can be janky. May need a fresh recovery image install instead.)
