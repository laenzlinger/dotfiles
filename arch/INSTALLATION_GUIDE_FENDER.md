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

## Phase 2: LUKS + Btrfs + Full Install (via switch-root)

### Step 1: Boot Normally and Get Networking

Boot into the minimal ALARM install, login as `root`/`root`. Networking with USB ethernet should work automatically.

```bash
ip link
ping -c1 archlinux.org
```

### Step 2: Install Tools and Note Partitions

```bash
pacman -Sy arch-install-scripts btrfs-progs cryptsetup

lsblk
blkid
```

Note the device names:

```bash
EFI_PART=/dev/nvme0n1pX   # ~500MB vfat (EFI)
ROOT_PART=/dev/nvme0n1pX  # large btrfs (current root)
```

### Step 3: Create Rescue Environment and Switch Into It

```bash
mkdir /run/rescue
mount -t tmpfs -o size=4G tmpfs /run/rescue
pacstrap -c /run/rescue base cryptsetup btrfs-progs arch-install-scripts

systemctl switch-root /run/rescue /bin/bash
```

After switch-root, networking is lost. Bring it back up manually:

```bash
ip link set eth0 up
dhcpcd eth0
# Verify:
ping -c1 archlinux.org
```

### Step 4: Unmount Old Root and Format LUKS

```bash
EFI_PART=/dev/nvme0n1pX   # same values as above
ROOT_PART=/dev/nvme0n1pX

# Verify old root is unmounted
mount | grep nvme
# If still mounted:
umount -l $ROOT_PART 2>/dev/null

cryptsetup luksFormat $ROOT_PART
# Type YES, enter passphrase

cryptsetup open $ROOT_PART cryptroot
```

### Step 5: Btrfs + Subvolumes

```bash
mkfs.btrfs /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt
```

### Step 6: Mount Everything

```bash
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{home,boot,.snapshots,var/log}

mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log

mount $EFI_PART /mnt/boot
```

### Step 7: Initialize Pacman Keys and Pacstrap

```bash
pacman-key --init
pacman-key --populate archlinuxarm

pacstrap -K /mnt base linux-asahi linux-firmware m1n1 uboot-asahi \
    asahi-scripts asahi-fwextract asahi-meta asahi-alarm-keyring \
    archlinuxarm-keyring speakersafetyd bankstown \
    btrfs-progs cryptsetup networkmanager sudo git vim zsh base-devel ly
```

### Step 8: Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab  # Verify
```

### Step 9: Chroot and Configure

```bash
arch-chroot /mnt
```

Inside chroot:

```bash
# Timezone + locale
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "fender" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   fender.home fender
EOF

# User
useradd -m -G wheel -s /bin/zsh laenzi
passwd laenzi
EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL

# Root password
passwd

# mkinitcpio — add encrypt hook
vim /etc/mkinitcpio.conf
# Set HOOKS:
# HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
mkinitcpio -P

# Bootloader
bootctl install
mkdir -p /boot/EFI/BOOT
cp /boot/EFI/systemd/systemd-bootaa64.efi /boot/EFI/BOOT/BOOTAA64.EFI

cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

# Get UUID of LUKS partition (NOT /dev/mapper/cryptroot)
blkid $ROOT_PART
# Copy the UUID value, use it below:

cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux ARM
linux   /vmlinuz-linux-asahi
initrd  /initramfs-linux-asahi.img
options cryptdevice=UUID=<UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet
EOF
# ^^^ REPLACE <UUID> with actual UUID

# Enable services
systemctl enable NetworkManager
systemctl enable speakersafetyd
systemctl enable systemd-timesyncd
systemctl enable systemd-resolved
systemctl enable ly@tty2

# Swapfile (8GB, no hibernation)
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

# Exit chroot
exit
```

### Step 10: Reboot

```bash
umount -R /mnt
cryptsetup close cryptroot
reboot -f
```

On reboot: LUKS passphrase prompt → systemd-boot → Arch Linux ARM.

---

## Phase 3: Post-Install

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

### Cannot Unmount Root for cryptsetup

If `mount -o remount,ro /` fails (device busy), kill remaining processes:
```bash
fuser -km /home
umount /home
mount -o remount,ro /
```

### systemd-boot Not Found by U-Boot

U-Boot looks for a specific EFI binary path. If it doesn't find systemd-boot:
```bash
# From chroot, ensure the EFI binary is where U-Boot expects it
cp /boot/EFI/systemd/systemd-bootaa64.efi /boot/EFI/BOOT/BOOTAA64.EFI
```

---

**Hardware:** MacBook Pro 16" M1, 1TB SSD, 32GB RAM
**Base:** Arch Linux ARM (ALARM) via Asahi
**Installation Date:** ___
