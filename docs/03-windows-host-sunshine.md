# Windows host: Sunshine + Virtual Display Driver

## What's installed

| Component | Version | Purpose |
|---|---|---|
| Sunshine | 2026.525.x | Stream server |
| MTT Virtual Display Driver | 11.30.4 | Virtual monitor for streaming-specific resolutions |
| MultiMonitorTool | x64 | (installed but unused — see "what didn't work") |
| OpenSSH Server | Windows built-in | Remote admin |

VDD lives at `C:\VirtualDisplayDriver\` with `vdd_settings.xml` controlling its modes.

## Sunshine config

Working `sunshine.conf` (sanitized version in [`scripts/host-windows/sunshine.conf.example`](../scripts/host-windows/sunshine.conf.example)):

```ini
dd_wa_hdr_toggle = enabled
encoder = nvenc
fps = [60,90,100,120,144]
nvenc_preset = 1
notify_pre_releases = enabled
qsv_preset = slowest
resolutions = [
    3840x2160,
    3456x2234,
    2560x1600,
    1920x1200,
    1920x1080
]
sunshine_name = Luke's Sunshine
upnp = enabled
```

Key settings:
- `nvenc_preset = 1` → P1, lowest latency NVENC preset (your 5090's 9th-gen NVENC handles this fine)
- `encoder = nvenc` → use the 5090's hardware encoder
- `dd_wa_hdr_toggle = enabled` → HDR workaround for display device toggle
- Resolutions list includes 1920×1200 for native Legion Go 2 streaming

## VDD configuration

Working `vdd_settings.xml` (full version in [`scripts/host-windows/vdd_settings.xml`](../scripts/host-windows/vdd_settings.xml)):

- **1920×1200 is FIRST** in the resolution list — that becomes the VDD's default mode when the driver initializes
- Global refresh rates: 60, 90, 120, 144, 165, 244 Hz (apply to all listed resolutions)
- `HardwareCursor` enabled, `HDRPlus` and `SDR10bit` disabled (conflicting features)

After editing the XML, the driver needs to reload to pick up changes. Two options:
1. Reboot Windows (most reliable)
2. `pnputil /remove-device <instance-id>` then `pnputil /scan-devices`

## Manually set the VDD's resolution

Once the VDD is recognized with new modes, set it to your target via Windows Display Settings:

1. Right-click desktop → **Display settings**
2. Pick the **VDD** display ("Generic Monitor (VDD by MTT)")
3. Resolution → **1920 × 1200**
4. **Advanced display** → Refresh rate → **120Hz**

Windows persists this setting; Sunshine then captures the VDD at that resolution.

## What didn't work (lessons learned)

### Auto-resolution-switching with do/undo scripts

Tried using Sunshine's `global_prep_cmd` to call MultiMonitorTool on stream start (disable physical monitors, set VDD primary, change res). **Failed** because:
- Sunshine runs as a Windows Service in Session 0
- MMT calls from Session 0 hang because they need an interactive desktop session
- Even direct `ChangeDisplaySettingsEx` P/Invoke fails from Session 0

### Sunshine's built-in `dd_resolution_option = automatic`

Set this hoping Sunshine would handle resolution switching internally. It DOES change the VDD's mode on stream start, but **picks the wrong mode** when the client request doesn't exactly match — falls back to the first/lowest entry (800×600 @ 30Hz) instead of finding the best match. Made the stream unusable.

**Solution we landed on**: manually set VDD resolution once via Display Settings. Sunshine streams it as-is. Both Mac Moonlight and Legion Moonlight clients work fine — they just downscale on receive.

## SSH into the host (we set up during the session)

```bash
ssh jerem@192.168.1.157
```

OpenSSH Server was installed via `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`. Firewall rule on TCP 22 was created.

For administrators, public keys must go in `C:\ProgramData\ssh\administrators_authorized_keys` with strict permissions (only Administrators + SYSTEM can read/write):

```powershell
$key = "ssh-ed25519 AAAAC3... your-key"
$authFile = "C:\ProgramData\ssh\administrators_authorized_keys"
Add-Content -Path $authFile -Value $key
icacls.exe $authFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
```

Disable SSH later if not needed:
```powershell
Stop-Service sshd
Set-Service sshd -StartupType Disabled
```
