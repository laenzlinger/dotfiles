# Arch Linux ARM Installation Guide - Fender (Apple Silicon)

**Hardware:** MacBook Pro M1 (2020/2021)
**Configuration:** Asahi Linux (m1n1 + U-Boot), LUKS encryption, btrfs with subvolumes, systemd-boot

---

## Overview

The Asahi installer handles Apple Silicon firmware and disk partitioning (UEFI stub via m1n1 + U-Boot). After the minimal install, we wipe the root filesystem it created and rebuild it with LUKS + btrfs, matching the gibson setup.

**Boot chain:** m1n1 → U-Boot → GRUB/systemd-boot → linux-asahi

---

## Phase 1: Asahi Installer

### Run the Asahi Installer from macOS

```bash
curl https://alx.sh | sh
```

- Choose **Arch Linux ARM (minimal)** — we only need the partition layout and firmware
- Allocate desired disk space when prompted
- Let it finish and reboot into the minimal ALARM environment

### First Boot — Note Partition Layout

After booting into the minimal Asahi install:

```bash
lsblk
```

Typical layout on NVMe (`/dev/nvme0n1`):

| Partition | Type | Purpose |
|-----------|------|---------|
| nvme0n1p1 | Apple APFS | macOS |
| nvme0n1p2 | Apple APFS | macOS Recovery |
| nvme0n1p3 | EFI (FAT32) | Asahi EFI partition (m1n1 + U-Boot) |
| nvme0n1p4 | Linux | Root (this is what we'll encrypt) |
| nvme0n1p5 | Linux | (may vary — check your layout) |

**Important:** Note which partition is the EFI partition and which is the Linux root. The EFI partition contains m1n1 and U-Boot — **never touch it**.

```bash
# Identify partitions
blkid
# Note the EFI partition (vfat) and the Linux root partition
```

---

## Phase 2: Prepare LUKS + Btrfs from Live Environment

### Boot a Live USB (or use the running minimal install)

You can do this from the running minimal Asahi install itself. Install required tools:

```bash
pacman -Sy arch-install-scripts btrfs-progs cryptsetup
```

### Identify Target Partition

The Linux root partition created by Asahi (e.g., `/dev/nvme0n1p5` — **verify with lsblk**):

```bash
# Unmount if currently mounted
umount -R /mnt 2>/dev/null || true

# If running from the installed system, unmount root is not possible.
# In that case, boot from USB or use a second partition.
# Alternative: resize and create a new partition for LUKS.
```

**Recommended approach:** Boot from an Arch Linux ARM USB or use `arch-install-scripts` from another partition. If the minimal install is the only option, you'll need to pivot — see "In-Place Conversion" below.

### In-Place Conversion (from running minimal Asahi install)

Since Apple Silicon can't easily boot arbitrary USB images, the practical approach is:

1. Back up the minimal install's boot files
2. Create a second partition or use the existing one with a pivot

**Simpler method — use Asahi's recovery:**

```bash
# From the running minimal install, note the root partition
ROOT_PART=/dev/nvme0n1p5  # VERIFY THIS
EFI_PART=/dev/nvme0n1p4   # VERIFY THIS - the one with m1n1/U-Boot

# Back up /boot contents (kernel, initramfs)
mkdir -p /tmp/boot-backup
cp -a /boot/* /tmp/boot-backup/

# Back up EFI contents
mkdir -p /tmp/efi-backup
mount $EFI_PART /mnt
cp -a /mnt/* /tmp/efi-backup/
umount /mnt
```

### Format with LUKS

```bash
# VERIFY the correct partition — this destroys data
cryptsetup luksFormat $ROOT_PART
# Type 'YES' and enter passphrase

# Open the encrypted partition
cryptsetup open $ROOT_PART cryptroot
```

### Create Btrfs with Subvolumes

```bash
mkfs.btrfs /dev/mapper/cryptroot

# Mount and create subvolumes
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

# Mount EFI partition
mount $EFI_PART /mnt/boot
```

---

## Phase 3: Install Base System

### Bootstrap Arch Linux ARM

```bash
pacstrap -K /mnt base linux-asahi linux-firmware m1n1 uboot-asahi \
    asahi-scripts asahi-fwextract asahi-meta asahi-alarm-keyring \
    archlinuxarm-keyring speakersafetyd \
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
# Note the UUID (of the LUKS container, not /dev/mapper/cryptroot)
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
```

### Root Password

```bash
passwd
```

---

## Phase 5: Swapfile (Optional — for Hibernation)

```bash
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none
dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress  # 16GB, adjust to RAM size
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

For hibernation, add `resume` hook and kernel parameters as in the gibson guide.

---

## Phase 6: Exit and Reboot

```bash
exit
umount -R /mnt
cryptsetup close cryptroot
reboot
```

On reboot, you should get the LUKS passphrase prompt, then boot into your encrypted btrfs system.

---

## Phase 7: Post-Install (from fender)

### Connect to Network

```bash
nmtui
```

### Install Packages from Chezmoi Lists

```bash
# Clone dotfiles
git clone https://github.com/<your-user>/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Run setup
bash arch/setup-user.sh
```

### Display Manager

```bash
sudo systemctl enable ly@tty2
```

---

## Troubleshooting

### Boot Chain Issues

The Apple Silicon boot chain is: m1n1 → U-Boot → systemd-boot → kernel. If boot fails:

- Hold power button to enter DFU/recovery
- m1n1 issues: re-run Asahi installer from macOS to reinstall firmware
- systemd-boot issues: boot macOS, mount the EFI partition, fix entries

### LUKS Not Prompting

Ensure `encrypt` hook is in mkinitcpio HOOKS before `filesystems`, and the `cryptdevice=` kernel parameter uses the correct UUID.

### Kernel Panics

Apple Silicon needs `linux-asahi` — the generic `linux` package won't work. Verify:

```bash
pacman -Q linux-asahi
```

### Speaker Safety

**Always** keep `speakersafetyd` enabled. Without it, the speakers can be physically damaged by the kernel driver.

---

**Target Hardware:** MacBook Pro M1
**Base:** Arch Linux ARM (ALARM) via Asahi
**Installation Date:** ___
