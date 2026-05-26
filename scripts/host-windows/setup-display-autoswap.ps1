# Auto-swap primary display between VDD and ROG STRIX on stream start/end.
#
# How it works:
#   - Two scheduled tasks (SetVDDPrimary, SetROGPrimary) registered to run
#     as the interactive user with InteractiveToken logon type.
#   - Each task runs MultiMonitorTool to swap the primary monitor.
#   - Sunshine's global_prep_cmd calls `schtasks /Run` to trigger them.
#   - Because the tasks run in the user's Session 1+ desktop, MMT actually
#     works (unlike calling MMT directly from Sunshine's Session 0 service).
#
# Prerequisites:
#   - MultiMonitorTool installed at C:\Tools\MultiMonitorTool\
#   - Run this script as administrator
#
# Customize for your hardware:
#   - Update MMT identifiers (MTT1337 = VDD, AUSAA06 = primary ROG)
#   - These come from `Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID`

$ErrorActionPreference = 'Continue'

$dir = "C:\Tools\display-scripts"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

# --- VDD primary + disable physical monitors ---
# Just setting VDD as primary isn't enough — games can launch on their
# remembered monitor (e.g., Resident Evil Requiem remembers which display
# it was on last). Disabling the physical monitors forces all windows to
# the VDD because that's the only active display.
$setVdd = @'
$ErrorActionPreference = 'SilentlyContinue'
$log = "$env:TEMP\display-swap.log"
$mmt = "C:\Tools\MultiMonitorTool\MultiMonitorTool.exe"

"=== $(Get-Date) Set-VDD-Primary ===" | Out-File $log -Append

# Step 1: make VDD primary first
& $mmt /SetPrimary "MTT1337" *>> $log
Start-Sleep -Milliseconds 800

# Step 2: disable the physical monitors (forces all windows onto VDD)
& $mmt /disable "AUSAA06" *>> $log
& $mmt /disable "AUS32F6" *>> $log

"Done." | Out-File $log -Append
'@

# --- ROG primary + re-enable physical monitors ---
$setRog = @'
$ErrorActionPreference = 'SilentlyContinue'
$log = "$env:TEMP\display-swap.log"
$mmt = "C:\Tools\MultiMonitorTool\MultiMonitorTool.exe"

"=== $(Get-Date) Set-ROG-Primary ===" | Out-File $log -Append

# Step 1: re-enable the physical monitors
& $mmt /enable "AUSAA06" *>> $log
& $mmt /enable "AUS32F6" *>> $log
Start-Sleep -Seconds 2

# Step 2: restore ROG STRIX as primary
& $mmt /SetPrimary "AUSAA06" *>> $log

"Done." | Out-File $log -Append
'@

Set-Content -Path "$dir\set-vdd-primary.ps1" -Value $setVdd -Encoding ASCII
Set-Content -Path "$dir\set-rog-primary.ps1" -Value $setRog -Encoding ASCII

# --- Register scheduled tasks ---
$psExe = (Get-Command powershell.exe).Source
$userPrincipal = "$env:COMPUTERNAME\$env:USERNAME"

function Register-OnDemandTask {
    param([string]$Name, [string]$Script)

    Unregister-ScheduledTask -TaskName $Name -Confirm:$false -ErrorAction SilentlyContinue

    $action = New-ScheduledTaskAction -Execute $psExe `
        -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script`""

    # InteractiveToken = runs in user's interactive session
    $principal = New-ScheduledTaskPrincipal -UserId $userPrincipal `
        -LogonType Interactive -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
        -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

    Register-ScheduledTask -TaskName $Name -Action $action `
        -Principal $principal -Settings $settings | Out-Null

    Write-Host "  Registered: $Name"
}

Register-OnDemandTask -Name "SetVDDPrimary" -Script "$dir\set-vdd-primary.ps1"
Register-OnDemandTask -Name "SetROGPrimary" -Script "$dir\set-rog-primary.ps1"

# --- Wire into Sunshine ---
$conf = "C:\Program Files\Sunshine\config\sunshine.conf"
$backup = "$conf.bak-$(Get-Date -Format yyyyMMddHHmmss)"
Copy-Item $conf $backup -Force
Write-Host "  Sunshine backed up to $backup"

$prepCmdJson = '[{"do":"cmd /c schtasks /Run /TN SetVDDPrimary","undo":"cmd /c schtasks /Run /TN SetROGPrimary","elevated":"true"}]'
$prepLine = "global_prep_cmd = $prepCmdJson"

$lines = Get-Content $conf
$output = $lines | Where-Object { $_ -notmatch '^global_prep_cmd\s*=' }
$output += $prepLine
$output | Set-Content -Path $conf -Encoding ASCII

Write-Host ""
Write-Host "  global_prep_cmd added"

Restart-Service SunshineService -Force
Start-Sleep -Seconds 4

Write-Host ""
Write-Host "Done. Test from PowerShell:"
Write-Host "  Start-ScheduledTask -TaskName SetVDDPrimary"
Write-Host "  Start-ScheduledTask -TaskName SetROGPrimary"
Write-Host ""
Write-Host "Or start a Moonlight stream - VDD becomes primary on stream start, ROG on stream end."
