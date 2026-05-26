# Auto-swap primary display on stream start/end

## The problem

Without this, games launched while streaming via Sunshine land on whichever monitor is currently primary — usually one of the physical 4K ROG STRIX panels. Sunshine captures the VDD, so:

> *Resident Evil Requiem launched on the ROG STRIX (which you can't see during stream). The Sunshine stream shows only the desktop on the VDD. The game runs forever in the background, never visible.*

## What we tried before (and why it failed)

**Direct MMT call from Sunshine's `global_prep_cmd`**: Sunshine runs as a Windows Service in Session 0. MultiMonitorTool needs an interactive desktop session (Session 1+) to manipulate display config. Calling MMT directly from Sunshine's service context **hangs forever** waiting on a session-0 API that can't complete.

**Sunshine's `dd_resolution_option = automatic`**: tried it, picked the lowest available VDD mode (800×600) instead of matching client request. Backed out.

## What works

**Scheduled Tasks running in the user's interactive session**, triggered via `schtasks /Run` from Sunshine's `global_prep_cmd`. This bridges Session 0 → Session 1 cleanly.

```
Sunshine service (Session 0)
  └─ global_prep_cmd: "cmd /c schtasks /Run /TN SetVDDPrimary"
                       ↓
              Windows Task Scheduler
                       ↓
           Task runs as user with InteractiveToken
                  in Session 1 (interactive desktop)
                       ↓
              MultiMonitorTool /SetPrimary MTT1337
                  → display config actually changes
```

Because `schtasks /Run` returns immediately (fire-and-forget), Sunshine doesn't block waiting for MMT.

## Tasks registered

| Task | What it does | Calls |
|---|---|---|
| `SetVDDPrimary` | Make VDD the primary display | `MultiMonitorTool.exe /SetPrimary MTT1337` |
| `SetROGPrimary` | Restore ROG STRIX as primary | `MultiMonitorTool.exe /SetPrimary AUSAA06` |

Both registered with:
- **Principal**: `jermspc\jerem` (interactive user)
- **LogonType**: Interactive (key — this is what makes them run in Session 1)
- **RunLevel**: Highest
- **Trigger**: none (on-demand only)

## Sunshine config

```ini
global_prep_cmd = [{"do":"cmd /c schtasks /Run /TN SetVDDPrimary","undo":"cmd /c schtasks /Run /TN SetROGPrimary","elevated":"true"}]
```

## Files

| Path | Purpose |
|---|---|
| `C:\Tools\display-scripts\set-vdd-primary.ps1` | Sets VDD primary, logs to `%TEMP%\display-swap.log` |
| `C:\Tools\display-scripts\set-rog-primary.ps1` | Sets ROG primary |
| `C:\Tools\MultiMonitorTool\MultiMonitorTool.exe` | NirSoft monitor control |
| Task Scheduler: `SetVDDPrimary`, `SetROGPrimary` | Triggered by Sunshine |

## Verifying it works

After setup, run from any PowerShell on the host:
```powershell
Start-ScheduledTask -TaskName SetVDDPrimary
# Watch your monitors — primary should swap to VDD
Start-ScheduledTask -TaskName SetROGPrimary
# Swap back
```

Check the swap log:
```powershell
Get-Content $env:TEMP\display-swap.log -Tail 20
```

End-to-end test: start a Moonlight stream from the Legion. The host's primary should swap to VDD. End the stream — primary returns to ROG STRIX.

## Troubleshooting

**Tasks fire but display doesn't change**: MMT can't find the monitor by name. Check the actual monitor IDs:
```powershell
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
    $name = -join ($_.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ })
    "$name -> $($_.InstanceName)"
}
```

The Short Monitor IDs (the AUSAA06 / MTT1337 part of the InstanceName) go in the scripts.

**Tasks don't run from Sunshine**: confirm Sunshine config has the line:
```powershell
Get-Content "C:\Program Files\Sunshine\config\sunshine.conf" | Select-String global_prep_cmd
```

**Display swap happens but on wrong monitor**: you have multiple monitors with the same model. Use the InstanceName ID instead of the short name in the scripts.

**Want to skip the swap for a specific stream**: there's no per-app override yet. Disable globally by removing `global_prep_cmd` from sunshine.conf and restart Sunshine.

## Reverting

Remove both:
```powershell
Unregister-ScheduledTask -TaskName SetVDDPrimary -Confirm:$false
Unregister-ScheduledTask -TaskName SetROGPrimary -Confirm:$false
```

Strip the line from sunshine.conf:
```powershell
$conf = "C:\Program Files\Sunshine\config\sunshine.conf"
(Get-Content $conf) | Where-Object { $_ -notmatch '^global_prep_cmd' } | Set-Content $conf
Restart-Service SunshineService
```
