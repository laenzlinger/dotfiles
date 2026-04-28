# Arch Linux

## Hardware

Lenovo ThinkPad X1 Carbon Gen 12
- 1TB NVMe SSD
- 32GB RAM
- Intel i7-1360P CPU
- US keyboard layout

## System

- Timezone: Europe/Zurich
- Locale: en_US.UTF-8
- Bootloader: systemd-boot
- Filesystem: btrfs with subvolumes
- Encryption: LUKS full disk
- AUR helper: yay

## Backups

Backups are done with restic via resticprofile. Backed up paths:
- `/home/laenzi`
- `/etc`
- `/boot`
- `/root`

Stored on external USB drive in directory `gibson-home`.

## DNS

DNS is handled by `systemd-resolved` (see [ADR 006](adr/006-systemd-resolved-for-dns.md)).

System config (not chezmoi-managed, backed up by restic):
- `/etc/resolv.conf` → symlink to `/run/systemd/resolve/stub-resolv.conf`
- `/etc/NetworkManager/conf.d/dns.conf` — `dns=systemd-resolved`

## Package lists

`chezmoi apply` generates package lists in `~/.config/pacman/`:
- `pkglist.txt` — official packages
- `foreignpkglist.txt` — AUR packages
- `optdeplist.txt` — optional dependencies

## Installation

See [arch/INSTALLATION_GUIDE.md](/arch/INSTALLATION_GUIDE.md) for the full step-by-step guide.
