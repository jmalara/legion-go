# Performance tweaks (Legion side)

System-level tweaks applied to the Legion Go 2's SteamOS install. Re-runnable scripts in [`scripts/legion-steamos/`](../scripts/legion-steamos/).

## What we did and why

| Setting | Was | Set to | Why |
|---|---|---|---|
| `vm.swappiness` | 60 (Linux default) | 10 | 22GB RAM + zram → no need to aggressively swap to disk |
| `vm.vfs_cache_pressure` | 100 | 50 | Keeps file cache around longer → fewer SSD reads on repeated game launches |
| CPU governor | `powersave` (SteamOS default) | `performance` | Cores ramp up immediately instead of lagging — reduces frame time variance |

## What we did NOT touch and why

| Setting | Current | Why leave it alone |
|---|---|---|
| NVMe scheduler | `none` | Already optimal for NVMe |
| ZRAM | 10.5GB zstd | Working great — better than disk swap |
| AMDGPU power level | `auto` | Forcing `high` always-on wrecks battery |
| Kernel mitigations | enabled | Security default, not worth the risk for ~1% perf |
| Wi-Fi power save | off | Already off (SteamOS default) |

## Applying the sysctl tweaks

These persist via `/etc/sysctl.d/99-legion-perf.conf`.

```bash
sudo steamos-readonly disable
sudo tee /etc/sysctl.d/99-legion-perf.conf > /dev/null <<EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF
sudo sysctl --system
sudo steamos-readonly enable
```

Or run [`scripts/legion-steamos/apply-sysctl-tweaks.sh`](../scripts/legion-steamos/apply-sysctl-tweaks.sh).

Verify:
```bash
sysctl vm.swappiness vm.vfs_cache_pressure
```

## Applying the CPU governor change

Persistent via a systemd service that runs on every boot.

```bash
sudo steamos-readonly disable
sudo cp scripts/legion-steamos/cpu-governor-performance.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cpu-governor-performance.service
sudo systemctl start cpu-governor-performance.service
sudo steamos-readonly enable
```

Verify (sample CPUs):
```bash
for c in /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor \
         /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor \
         /sys/devices/system/cpu/cpu15/cpufreq/scaling_governor; do
  echo "$c: $(cat $c)"
done
```

Should print `performance` for each.

## Reverting

Remove the sysctl file:
```bash
sudo steamos-readonly disable
sudo rm /etc/sysctl.d/99-legion-perf.conf
sudo steamos-readonly enable
sudo sysctl --system
```

Disable the governor service:
```bash
sudo systemctl disable cpu-governor-performance.service
sudo reboot
```

## After major SteamOS updates

`/etc` can be overwritten on major upgrades. After a big update, verify settings persisted:

```bash
sysctl vm.swappiness                                          # expect 10
systemctl is-enabled cpu-governor-performance.service         # expect enabled
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor     # expect performance
```

If any are reset, re-run the scripts.

## Per-game performance settings (not done globally)

These you set per-game in Steam:

- **Framerate cap** (Properties → Performance): match a divisor of 144Hz (24/30/36/48/72) for clean frame pacing with VRR
- **GameScope filter**: FSR Quality for non-native, Integer for pixel art, never Bilinear
- **Refresh rate**: leave at 144Hz, let VRR handle dips
- **HDR**: enable per-game (Display settings → HDR → On)
