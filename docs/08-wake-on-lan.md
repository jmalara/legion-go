# Wake-on-LAN: wake the host from sleep over the network

You don't need to leave the gaming PC running 24/7. Configure it to wake on a magic packet, and call `wake-host.sh` from the Legion (or Mac) right before you stream.

## Host MAC

```
50-EB-F6-CE-2B-EB    (Intel I225-V Ethernet, 2.5 Gbps)
```

If you swap NICs, update [`scripts/wake-host.sh`](../scripts/wake-host.sh).

## What's configured on the host (already done)

1. **Fast Startup disabled** — `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\HiberbootEnabled = 0`. Without this, "shutdown" was actually a hybrid hibernation that breaks WoL.
2. **Magic Packet wake enabled** on the adapter:
   ```powershell
   Enable-NetAdapterPowerManagement -Name Ethernet -WakeOnMagicPacket
   ```
3. **Wake from device allowed** in power config:
   ```powershell
   powercfg /deviceenablewake "Intel(R) Ethernet Controller (3) I225-V"
   ```

⚠️ **Reboot required** for these to take full effect (NVIDIA settings included).

## Sending the wake from Mac / Legion

```bash
./scripts/wake-host.sh
```

The script uses pure `python3` + `socket` — no extra packages needed. Works on macOS and SteamOS.

To wake a different host:
```bash
./scripts/wake-host.sh 11:22:33:44:55:66 192.168.1.255
```

## Verify WoL works

1. Reboot the host once (so all the new settings load)
2. Shut it down properly (not sleep, full shutdown)
3. Wait 30 seconds
4. From the Mac: `./scripts/wake-host.sh`
5. Wait 30-60 seconds, then try `ssh jerem@192.168.1.157`

If it doesn't wake:
- Confirm `HiberbootEnabled = 0` is actually set (sometimes Group Policy reverts)
- Check BIOS: most BIOSes have "Wake on PCIe" / "Wake on LAN" settings that need to be enabled
- Verify the adapter still has Magic Packet wake enabled (Windows updates occasionally reset NIC driver settings):
  ```powershell
  Get-NetAdapterPowerManagement -Name Ethernet
  ```

## From SteamOS Game Mode

Open Konsole (Desktop Mode) or use SSH. The script is in this repo. If you want to call it without dropping out of Game Mode, options:

- **Add to Sunshine's `do` command** for a specific app — wakes host as part of stream prep (chicken-and-egg, only works if Sunshine itself is already running)
- **Better**: write a small Decky plugin that calls it — overkill
- **Practical**: just SSH from your phone (Termux, Prompt.app) and call `~/legion-go/scripts/wake-host.sh`

## Caveats

- WoL only works on the **same LAN broadcast domain**. From outside your home network, set up Tailscale or similar.
- Some routers drop broadcast UDP. If wake fails despite Windows settings being correct, check router settings.
- Power supplies that fully cut power (some surge protectors with auto-off) defeat WoL. The NIC needs standby power.
