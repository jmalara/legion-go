# Legion Go 2: SteamOS install & initial setup

## Recovery image

Use the latest Valve recovery image. As of 2026-05-25, the newest one with a `-repair-` zip (the USB installer) was **3.9.0 from 2026-05-11**:

```
https://steamdeck-images.steamos.cloud/steamdeck/20260511.1000/steamdeck-repair-20260511.1000-3.9.0.img.zip
```

Browse the index for newer builds: https://steamdeck-images.steamos.cloud/steamdeck/

Older Valve "official download" link (3.8.0 from August 2025) is outdated — skip it.

## Flashing the USB

On Mac with Balena Etcher:
1. Download the `.img.zip` (don't unzip — Etcher reads it directly)
2. Plug USB drive (8GB+, USB-C or with USB-C adapter for the Legion)
3. Etcher → Flash from file → pick the .zip → pick the drive → flash
4. macOS will pop up "disk not readable" multiple times during flash — always **Ignore**, never Initialize

## Booting from USB on Legion Go 2

1. Fully power off (hold power → Shut down, not sleep)
2. Plug USB into Legion's USB-C
3. Hold **Volume Up** + press Power → keep holding Volume Up until boot menu shows (~5 sec)
4. Select the USB drive from the list

Reference for button combos:
- **Volume Up + Power** → one-time boot menu
- **Volume Down + Power** → BIOS setup

## Install

SteamOS recovery image lands in a KDE desktop with installer icon. Click "Reimage Steam Deck" → confirm. ~15-20 min. Wipes the internal SSD.

## First boot

- Connect Wi-Fi
- Sign into Steam
- Let updates complete

Note: when SteamOS came up for the first time, version reported was actually `3.8.5` even though the recovery image was 3.9.0. The 3.9.0 image installs a 3.8.x base that updates to 3.9 after boot — or some such. Doesn't matter for our purposes.

## Switching to Desktop Mode

On Legion Go 2 the "Steam button" is the **Legion L** button (top-front of left controller, near the joystick). Press it → **Power** → **Switch to Desktop**.

If Legion L doesn't open the menu (button mapping incomplete on stock SteamOS), use the touchscreen — tap the Steam icon in the bottom-left corner of the screen.

## Setting the deck user password

By default `deck` has no password. To use `sudo`:

```bash
# In Konsole on Legion (Desktop Mode)
passwd
```

## Enabling SSH (optional but useful)

```bash
sudo systemctl enable --now sshd
```

Find IP:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

Authorize a key:
```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "ssh-ed25519 AAAAC3... your-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Disabling SSH when done

```bash
sudo systemctl disable --now sshd
```

## Critical SteamOS-specific quirks to remember

- **Rootfs is read-only by default**. To install anything outside Flatpak:
  ```bash
  sudo steamos-readonly disable
  # ... do your thing ...
  sudo steamos-readonly enable
  ```
- **`/etc` survives updates** but can be overwritten by major version bumps — re-apply tweaks after big updates
- **`pacman` keyring is not writable** even with steamos-readonly disabled in some cases. Often safer to install via Flatpak or by downloading binaries directly to `~/`
