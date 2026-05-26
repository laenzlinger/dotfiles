# Arch Linux ARM Installation Guide - Fender (Apple Silicon)

**Hardware:** MacBook Pro 16" M1 (2021), 1TB SSD, 32GB RAM
**Configuration:** Asahi Linux (m1n1 + U-Boot), LUKS encryption, btrfs with subvolumes, systemd-boot
**Dual-boot:** Minimal macOS partition retained (firmware updates require macOS)

---

## Overview

The Asahi installer handles Apple Silicon firmware and disk partitioning (UEFI stub via m1n1 + U-Boot). After the minimal install, we wipe the root filesystem it created and rebuild it with LUKS + btrfs, matching the gibson setup.

**Boot chain:** m1n1 → U-Boot → systemd-boot → linux-asahi

---

## Phase 1: Asahi ALARM Installer

### Shrink macOS from macOS

Before running the installer, shrink the APFS container in Disk Utility to the minimum (~70GB for macOS + recovery + firmware updates). This maximizes space for Linux.

### Run the Installer from macOS Terminal

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

- Choose **"Asahi Alarm Minimal (BTRFS)"**
- Allocate all remaining space (~900GB) to Linux
- Let it finish and reboot into the minimal ALARM environment
- Login as `root`/`root`

The installer creates two partitions:
- **EFI** (500MB FAT32) — contains m1n1 + U-Boot firmware. **Never touch.**
- **Root** (remaining space) — btrfs with `@` and `@home` subvolumes

### First Boot — Identify Partitions

```bash
lsblk
blkid
```

Note the device names:

```bash
EFI_PART=/dev/nvme0n1pX   # the vfat/EFI one (~500MB)
ROOT_PART=/dev/nvme0n1pX  # the btrfs one (large)
```

---

## Phase 2: LUKS + Btrfs (from running minimal install)

### Install Tools

```bash
pacman -Sy arch-install-scripts btrfs-progs cryptsetup rsync
```

### Pivot Root to RAM

Since we need to wipe the running root partition, pivot to a tmpfs:

```bash
mkdir /tmp/tmproot
mount -t tmpfs none /tmp/tmproot
mkdir -p /tmp/tmproot/{usr,dev,proc,sys,run,tmp,mnt}

# Copy userspace (Arch uses merged /usr)
rsync -a /usr/ /tmp/tmproot/usr/
ln -s usr/bin /tmp/tmproot/bin
ln -s usr/lib /tmp/tmproot/lib
ln -s usr/sbin /tmp/tmproot/sbin

# Pivot
mount --bind /dev /tmp/tmproot/dev
mount --bind /proc /tmp/tmproot/proc
mount --bind /sys /tmp/tmproot/sys

pivot_root /tmp/tmproot /tmp/tmproot/mnt
cd /

# Unmount old root
umount -l /mnt 2>/dev/null || true
```

### Format with LUKS

```bash
cryptsetup luksFormat $ROOT_PART
# Type 'YES' and enter passphrase

cryptsetup open $ROOT_PART cryptroot
```

### Create Btrfs with Subvolumes

```bash
mkfs.btrfs /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt
```

### Mount Subvolumes

```bash
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{home,boot,.snapshots,var/log}

mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log

mount $EFI_PART /mnt/boot
```

---

## Phase 3: Install Base System

### Bootstrap

```bash
pacstrap -K /mnt base linux-asahi linux-firmware m1n1 uboot-asahi \
    asahi-scripts asahi-fwextract asahi-meta asahi-alarm-keyring \
    archlinuxarm-keyring speakersafetyd bankstown \
    btrfs-progs cryptsetup networkmanager sudo git vim zsh base-devel
```

### Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab  # Verify
```

### Chroot

```bash
arch-chroot /mnt
```

---

## Phase 4: System Configuration

### Timezone, Locale, Hostname

```bash
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "fender" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   fender.home fender
EOF
```

### User Account

```bash
useradd -m -G wheel -s /bin/zsh laenzi
passwd laenzi

EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### Configure mkinitcpio for LUKS

```bash
vim /etc/mkinitcpio.conf
```

Set HOOKS:

```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

Regenerate:

```bash
mkinitcpio -P
```

### Bootloader (systemd-boot)

```bash
bootctl install
```

Get UUID of the LUKS partition:

```bash
blkid $ROOT_PART
# Note the UUID (of the LUKS container, NOT /dev/mapper/cryptroot)
```

```bash
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux ARM
linux   /vmlinuz-linux-asahi
initrd  /initramfs-linux-asahi.img
options cryptdevice=UUID=<UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet
EOF
```

**Replace `<UUID>`** with the actual UUID from `blkid`.

### Enable Services

```bash
systemctl enable NetworkManager
systemctl enable speakersafetyd
systemctl enable systemd-timesyncd
systemctl enable systemd-resolved
systemctl enable ly@tty2
```

### Root Password

```bash
passwd
```

---

## Phase 5: Swapfile

No hibernation — just a small swap for memory pressure:

```bash
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress  # 8GB
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

---

## Phase 6: Exit and Reboot

```bash
exit
umount -R /mnt
cryptsetup close cryptroot
reboot
```

On reboot: LUKS passphrase prompt → systemd-boot → Arch Linux ARM.

---

## Phase 7: Post-Install

### Connect to Network

```bash
nmtui
```

### Install Packages from Chezmoi Lists

```bash
git clone https://github.com/laenzlinger/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
bash arch/setup-user.sh
```

---

## Troubleshooting

### Boot Chain Issues

m1n1 → U-Boot → systemd-boot → kernel. If boot fails:

- Hold power button for DFU/recovery
- m1n1 issues: re-run Asahi installer from macOS
- systemd-boot issues: boot macOS, mount EFI partition, fix entries

### LUKS Not Prompting

Ensure `encrypt` hook is before `filesystems` in mkinitcpio HOOKS, and `cryptdevice=` uses the correct UUID.

### Kernel Panics

Must use `linux-asahi` — generic `linux` won't work on Apple Silicon.

### Speaker Safety

**Always** keep `speakersafetyd` enabled. Without it, speakers can be physically destroyed.

### Pivot Root Fails

If `pivot_root` doesn't work (not enough RAM for tmpfs, processes won't release old root):
- Rerun the installer from macOS choosing **"UEFI environment only"** — this gives just m1n1 + U-Boot + ESP with no root partition
- Then create and format the root partition manually with `gdisk` from macOS recovery or another Linux system

---

**Hardware:** MacBook Pro 16" M1, 1TB SSD, 32GB RAM
**Base:** Arch Linux ARM (ALARM) via Asahi
**Installation Date:** ___
