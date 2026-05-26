# Known issues & workarounds

Bugs and limitations encountered during setup. Each has a workaround or a tradeoff.

## Brightness slider dead after sleep/wake

**Symptom**: Brightness slider in Quick Access works on fresh boot, breaks after the device suspends and wakes — no longer changes screen brightness for the rest of the session. Only affects Game Mode (Gamescope session); Desktop Mode (KDE) brightness works fine.

**Cause**: Confirmed bug on Legion Go 2 + AMD Z2E hardware. Tracked in:
- [ValveSoftware/SteamOS#2368](https://github.com/ValveSoftware/SteamOS/issues/2368)
- [ValveSoftware/gamescope#1987](https://github.com/ValveSoftware/gamescope/issues/1987)

**Fixes (in order of best to fallback)**:
1. **Install the Decky plugin**: [Legion Go 2 Brightness fix CachyOS](https://github.com/jorgemmsilva/decky-plugin-fix-lego2-brightness-cachyos) — provides its own slider that bypasses the broken pipeline
2. **Reboot** if slider stops working mid-session (workaround, not a fix)
3. **CLI workaround**: use `legion-bright.sh` script (see [`scripts/legion-steamos/legion-bright.sh`](../scripts/legion-steamos/legion-bright.sh))

The kernel-level brightness file `/sys/class/backlight/amdgpu_bl0/brightness` is writable by the `deck` user — the bug is in the Gamescope-to-kernel path, not permissions.

## Decky Quick Access menu showing React error

**Symptom**: Opening Decky panel shows "An error occurred while rendering this content" with options to retry, restart Steam, or disable Decky. Console (if visible) reports `Minified React error #31`.

**Cause**: Steam UI update broke Decky's React component injection. Steam and Decky are locked in a perpetual cat-and-mouse.

**Workarounds**:
1. **Restart Steam**: Steam menu → Exit Steam → relaunch
2. **Restart Decky**: `sudo systemctl restart plugin_loader.service`
3. Update Decky (latest catches most Steam UI changes within days)
4. Disable plugins one-by-one to identify culprit

## HHD officially blocked on stock SteamOS

**Symptom**: Running `curl -L https://github.com/hhd-dev/hhd/raw/master/install.sh | bash` exits with:
> Installing Handheld Daemon on SteamOS is not canon.
> Did you mean to install Bazzite? https://bazzite.gg

**Cause**: HHD maintainers intentionally don't support stock SteamOS — they push users to Bazzite (which pre-installs HHD with proper integration).

**Workarounds**:
1. **Bypass** the check: `BYPASS_STEAMOS_CHECK=1 curl ... | bash` — unsupported, no help if it breaks
2. **Use LegionGoRemapper** (Decky plugin) instead — partial replacement, has Legion Go 2 support as of v0.3.0
3. **Switch to Bazzite** — proper HHD pre-installed

We went with LegionGoRemapper + SimpleDeckyTDP. Covers most of what HHD does on Legion Go.

## VDD on Windows resets to 800×600 after driver restart

**Symptom**: After `Disable-PnpDevice` + `Enable-PnpDevice` on the VDD (to reload its `vdd_settings.xml`), the virtual monitor comes back at the **first listed resolution** in the XML — which was 800×600 by default. Then Sunshine captures at 800×600 and streams look terrible.

**Fix**: Put your **preferred default resolution FIRST** in `vdd_settings.xml`. Our config puts `1920×1200 @ 120Hz` first. The driver defaults to that on initialization.

After ANY driver restart, also manually set the resolution in Windows Display Settings (Display → VDD → 1920×1200 @ 120Hz). Windows then remembers the preference across restarts.

## Sunshine `dd_resolution_option = automatic` picks wrong mode

**Symptom**: Enabling `dd_resolution_option = automatic` makes Sunshine switch the VDD's resolution on stream start, but it picks the LOWEST resolution that matches instead of the best match. Streams come up at 800×600.

**Fix**: We disabled this and manually set VDD resolution. Comment out or remove `dd_resolution_option`, `dd_refresh_rate_option`, `dd_configuration_option`, and `dd_hdr_option` from `sunshine.conf` if you have the same issue.

## MultiMonitorTool can't control displays from Sunshine prep_cmd

**Symptom**: A `global_prep_cmd` calling `MultiMonitorTool.exe /SetPrimary` hangs forever. Sunshine waits for the do command to complete. Moonlight stuck on "Starting Desktop..."

**Cause**: Sunshine runs as a Windows Service in Session 0. MMT (and most display config APIs) need an interactive desktop session.

**Workarounds**:
1. **Don't use do/undo for display switching** — set VDD resolution manually instead
2. Hypothetical: run Sunshine as a user process (not service) — fragile, not recommended
3. Use Sunshine's built-in `dd_*_option` config — except those have their own issues (see above)

We landed on: no do/undo, no `dd_*_option` automatic, manual VDD resolution setting.

## Steam's brightness slider value doesn't match what's set

If you have the brightness fix plugin installed, the **Steam slider** and the **plugin slider** may show different values because they're not in sync. Trust the plugin's slider — that's the one that's actually controlling brightness.

## Mac Moonlight requested 800×600

**Symptom**: Streaming from Mac to host showed everything at 800×600 even when settings looked correct.

**Cause**: Mac Moonlight's resolution setting was on a default that didn't match anything in Sunshine's offered list. Combined with `dd_resolution_option = automatic`, Sunshine fell back to the smallest available res.

**Fix**: Set Mac Moonlight resolution **explicitly** to a real value (1920×1200, 2560×1440, etc.) in its settings. Don't leave it on "auto" or default.

## Touch gestures vs button mappings on Legion Go 2

On Legion Go 2, the small buttons next to joysticks (View, Menu, M1/M2/M3, Quick Access) may not all be mapped. The **Legion L** button works as the Steam button. Other buttons may need LegionGoRemapper config or remain unmapped.

In Game Mode UI navigation, falling back to **touchscreen taps** works reliably.

## "Starting Desktop..." spinner forever

If Moonlight gets stuck on the loading spinner, the most common causes:
1. `global_prep_cmd` script hung (see MMT issue above) — kill the cmd.exe on host
2. Sunshine waiting on a state that won't resolve — restart `SunshineService`
3. Wrong codec selected for client → check client codec setting matches host capabilities
