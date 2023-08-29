# QubesOS Mode Toggler

This script toggles system settings between 'office' and 'travel' modes on QubesOS, accounting for those who use their laptop with a dock and don't want to burn out the battery while also using a USB mouse and keyboard, but also those who don't want the USB and power settings to persist while traveling.

## Features

- **Office Mode**
  - Sets specific battery charging thresholds.
  - Allows USB attachments to dom0 for use with keyboard/mouse and a docking station.
  
- **Travel Mode**
  - Sets the battery to fully charge.
  - Denies USB attachments for enhanced security on the go.

## Usage

1. To set **office mode**: ```toggle_mode office```
2. To set **travel mode**: ```toggle_mode travel```

## Caution

- **Backup** your system settings, especially the GRUB configuration, before applying changes.
- The script assumes you are using legacy boot. If you're using EFI boot, change the grub2-mkconfig command to: ```grub2-mkconfig -o /boot/efi/EFI/qubes/grub.cfg```
- Test the script in a safe environment first. Incorrect modifications can lead to unintended behavior.
- Keep the RPC policies in mind when using this script, and ensure that they align with your security needs.

## Installation
```
git clone https://github.com/kennethrrosen/qubes-mode-toggler/
cd [repo directory]
chmod +x toggle_mode.sh
```
