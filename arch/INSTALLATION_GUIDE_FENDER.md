# Arch Linux ARM Installation Guide - Fender (Apple Silicon)

**Hardware:** MacBook Pro 16" M1 (2021), 1TB SSD, 32GB RAM
**Configuration:** Asahi Linux (m1n1 + U-Boot), LUKS encryption, btrfs with subvolumes, systemd-boot
**Dual-boot:** Minimal macOS partition retained (firmware updates require macOS)

---

## Overview

The Asahi installer handles Apple Silicon firmware and disk partitioning (UEFI stub via m1n1 + U-Boot). After the minimal install, we wipe the root filesystem it created and rebuild it with LUKS + btrfs, matching the gibson setup.

**Boot chain:** m1n1 → U-Boot → systemd-boot → linux-asahi

---

## Phase 1: Asahi Installer

### Shrink macOS from macOS

Before running the installer, shrink the APFS container in Disk Utility to the minimum (~70GB for macOS + recovery + firmware updates). This maximizes space for Linux.

### Run the Asahi Installer

```bash
curl https://alx.sh | sh
```

- Choose **Arch Linux ARM (minimal)** — we only need the partition layout and firmware
- Allocate all remaining space (~900GB) to Linux
- Let it finish and reboot into the minimal ALARM environment

### First Boot — Note Partition Layout

After booting into the minimal Asahi install:

```bash
lsblk
blkid
```

Note:
- **EFI partition** (vfat, ~500MB) — contains m1n1 + U-Boot, **never touch**
- **Linux root partition** — this gets encrypted

```bash
# Store for later use
EFI_PART=/dev/nvme0n1pX   # the vfat one with EFI
ROOT_PART=/dev/nvme0n1pX  # the ext4/linux one
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
# Create a minimal rootfs in RAM
mkdir /tmp/tmproot
mount -t tmpfs none /tmp/tmproot
mkdir -p /tmp/tmproot/{bin,sbin,lib,usr,dev,proc,sys,run,tmp,mnt,boot-backup}

# Copy essential binaries
rsync -a /usr/ /tmp/tmproot/usr/
rsync -a /bin/ /tmp/tmproot/bin/ 2>/dev/null || true
rsync -a /sbin/ /tmp/tmproot/sbin/ 2>/dev/null || true
rsync -a /lib/ /tmp/tmproot/lib/ 2>/dev/null || true

# Back up boot files
cp -a /boot/* /tmp/tmproot/boot-backup/

# Pivot
mount --bind /dev /tmp/tmproot/dev
mount --bind /proc /tmp/tmproot/proc
mount --bind /sys /tmp/tmproot/sys

pivot_root /tmp/tmproot /tmp/tmproot/mnt
cd /

# Kill processes using old root, unmount it
fuser -km /mnt 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
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

If `pivot_root` doesn't work cleanly, alternative: boot macOS, use `diskutil` to identify the Linux partition, then boot back into Asahi recovery to do the conversion from there.

---

**Hardware:** MacBook Pro 16" M1, 1TB SSD, 32GB RAM
**Base:** Arch Linux ARM (ALARM) via Asahi
**Installation Date:** ___
