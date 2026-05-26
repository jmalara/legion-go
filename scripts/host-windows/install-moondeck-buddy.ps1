# Install MoonDeck Buddy on the Windows host as a portable app.
# Downloads the 7z (not the installer .exe — that needs interactive UAC).
# Extracts to C:\Tools\MoonDeckBuddy, registers HKCU autostart, launches.
#
# Requires: 7-Zip already installed (for extraction) or tar (Win10+).
# Run from an elevated PowerShell (some operations need admin).

$ErrorActionPreference = 'Stop'

$ver = "1.9.2"
$url = "https://github.com/FrogTheFrog/moondeck-buddy/releases/download/v$ver/MoonDeckBuddy-$ver-win64.7z"
$dest = "$env:TEMP\MoonDeckBuddy.7z"
$extractDir = "C:\Tools\MoonDeckBuddy"
$buddyExe = "$extractDir\MoonDeckBuddy-$ver-win64\bin\MoonDeckBuddy.exe"

Write-Host "=== Downloading MoonDeck Buddy v$ver ==="
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
Write-Host "  $((Get-Item $dest).Length) bytes"

Write-Host ""
Write-Host "=== Extracting to $extractDir ==="
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

$sevenZip = $null
foreach ($c in @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe",
    "C:\Program Files\Sunshine\third-party\7zip\7z.exe"
)) {
    if (Test-Path $c) { $sevenZip = $c; break }
}

if ($sevenZip) {
    & $sevenZip x $dest "-o$extractDir" -y | Select-Object -Last 5
} else {
    Write-Host "  No 7-Zip found. Falling back to tar (Win10+)..."
    & tar -xf $dest -C $extractDir
}

if (-not (Test-Path $buddyExe)) {
    throw "Extraction failed — $buddyExe not found"
}
Write-Host "  $buddyExe present"

Write-Host ""
Write-Host "=== Registering autostart in HKCU Run ==="
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "MoonDeckBuddy" `
    -Value ('"' + $buddyExe + '"') -Type String

Write-Host ""
Write-Host "=== Launching MoonDeck Buddy ==="
$existing = Get-Process MoonDeckBuddy -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "  Already running, PID $($existing.Id)"
} else {
    Start-Process -FilePath $buddyExe
    Start-Sleep -Seconds 3
    $existing = Get-Process MoonDeckBuddy -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  Started, PID $($existing.Id)"
    } else {
        Write-Host "  NOT visible in this session. Manually launch via Start menu or by re-running this script from an interactive session."
    }
}

Write-Host ""
Write-Host "=== Checking listening port 59999 ==="
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -eq 59999 } |
    Format-Table LocalPort, OwningProcess -AutoSize

Remove-Item $dest -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "DONE. Buddy is at $buddyExe, auto-starts on login, listens on 59999."
Write-Host "Next: pair MoonDeck on the Legion with this host's IP + PIN."
