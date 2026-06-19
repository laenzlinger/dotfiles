# Arch Linux ARM Installation Guide - Fender (Apple Silicon)

**Hardware:** MacBook Pro 16" M1 (2021), 1TB SSD, 32GB RAM
**Configuration:** Asahi Linux (m1n1 + U-Boot + GRUB), LUKS encryption, btrfs with subvolumes
**Dual-boot:** Minimal macOS partition retained (firmware updates require macOS)

---

## Overview

The Asahi installer handles Apple Silicon firmware and disk partitioning (UEFI stub via m1n1 + U-Boot).
After the minimal install, we move `/boot` to the EFI partition (kernel + initramfs unencrypted),
then encrypt the root partition **in-place** using `cryptsetup reencrypt`.
The initramfs `encrypt` hook handles LUKS unlock at boot.

This matches the gibson (ThinkPad) setup: unencrypted `/boot` on EFI, encrypted root.

**Boot chain:** m1n1 → U-Boot → GRUB → kernel (from EFI) → initramfs unlocks LUKS → root

---

## Phase 1: Asahi ALARM Installer

### Shrink macOS from macOS

Before running the installer, shrink the APFS container in Disk Utility to the minimum
(~70GB for macOS + recovery + firmware updates). This maximizes space for Linux.

### Run the Installer from macOS Terminal

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

- Choose **"Asahi Alarm Minimal (BTRFS)"**
- Allocate all remaining space (max) to Linux
- Let it finish and reboot into the minimal ALARM environment
- Login as `root`/`root`

The installer creates two partitions:
- **EFI** (~500MB FAT32) — contains m1n1 + U-Boot + GRUB EFI binary
- **Root** (remaining space) — btrfs with `@` and `@home` subvolumes

### First Boot — Identify Partitions

```bash
lsblk
blkid
```

Note the device names (example):

```bash
EFI_PART=/dev/nvme0n1p4   # the vfat/EFI one (~500MB)
ROOT_PART=/dev/nvme0n1p5  # the btrfs one (large)
```

---

## Phase 2: Move /boot to EFI Partition

We put the kernel, initramfs, and GRUB config on the unencrypted EFI partition.
This way GRUB never needs to unlock LUKS — only the initramfs does (with reliable keyboard).

### Step 1: Get Networking

```bash
ip link
ping -c1 archlinux.org
# If wifi:
# nmcli device wifi connect <SSID> password <password>
```

### Step 2: Install Required Tools

```bash
pacman -Sy cryptsetup efibootmgr btrfs-progs inetutils git base-devel
```

### Step 3: Move /boot to EFI Partition

```bash
# Check current EFI mount
mount | grep efi

# Unmount EFI from /boot/efi
umount /boot/efi

# Copy everything from /boot to EFI partition
mount /dev/nvme0n1p4 /mnt
cp -a /boot/* /mnt/
umount /mnt

# Remount EFI as /boot
umount /boot 2>/dev/null
mount /dev/nvme0n1p4 /boot

# Update fstab: change EFI mount from /boot/efi to /boot
vi /etc/fstab
# Change the EFI partition mount point from /boot/efi to /boot
# Remove any old /boot entry if present
```

### Step 4: Reinstall GRUB on EFI Partition

```bash
grub-install --target=arm64-efi --efi-directory=/boot
cp /boot/EFI/arch/grubaa64.efi /boot/EFI/BOOT/BOOTAA64.EFI
grub-mkconfig -o /boot/grub/grub.cfg
```

### Step 5: Test Reboot

```bash
reboot
```

**Verify the system boots normally before proceeding.** If it doesn't boot, fix GRUB
from the GRUB rescue prompt: `set prefix=(hd0,gpt4)/grub` then `insmod normal` then `normal`.

---

## Phase 3: In-Place LUKS Encryption

### Step 1: Shrink Btrfs (make room for LUKS header)

Shrink by **256 MiB** (generous margin — btrfs rounds internally):

```bash
btrfs filesystem show /
btrfs filesystem resize 1:-256m /
btrfs filesystem show /
```

**Verify the size actually decreased.**

### Step 2: Add Encrypt Hook to Initramfs

```bash
sed -i 's/block filesystems/block encrypt filesystems/' /etc/mkinitcpio.conf
grep ^HOOKS /etc/mkinitcpio.conf   # verify encrypt is before filesystems
mkinitcpio -P
```

### Step 3: Add `break` to GRUB Boot Entry

```bash
sed -i '/^\s*linux \/vmlinuz/{/break/!s/$/ break/}' /boot/grub/grub.cfg
grep 'break' /boot/grub/grub.cfg   # verify
```

### Step 4: Reboot into Initramfs Shell

```bash
reboot
```

You will land in a root shell (before root is mounted). The root partition is **not in use**.

### Step 5: Encrypt the Partition In-Place

```bash
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp
cd /tmp
cryptsetup reencrypt --encrypt --reduce-device-size=32M --force-password /dev/nvme0n1p5
```

- Type `YES` when prompted
- Enter and verify your LUKS passphrase
- Wait for completion (~20-25 minutes for ~900GB)

Uses argon2id by default (strongest KDF). GRUB doesn't need to unlock this — only the
initramfs does, which has full argon2id support.

---

## Phase 4: Configure Boot for Encrypted Root

Still in the initramfs shell after encryption completes.

### Step 1: Open LUKS and Mount

```bash
cryptsetup open /dev/nvme0n1p5 cryptroot
mkdir /mnt
mount -o subvol=@ /dev/mapper/cryptroot /mnt
mount /dev/nvme0n1p4 /mnt/boot
```

### Step 2: Chroot In

```bash
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /dev /mnt/dev
chroot /mnt
```

### Step 3: Fix /etc/fstab

```bash
vi /etc/fstab
```

- Change the root (`/`) and `/home` lines: replace UUID with `/dev/mapper/cryptroot`
- Remove `x-systemd.growfs` if present
- Ensure `/boot` points to the EFI partition (should already be correct)

### Step 4: Update GRUB Configuration

```bash
U=$(blkid -s UUID -o value /dev/nvme0n1p5)
echo $U >> /etc/default/grub
vi /etc/default/grub
```

In vim:
- Delete the old `GRUB_CMDLINE_LINUX=""` line
- Build the UUID line into: `GRUB_CMDLINE_LINUX="cryptdevice=UUID=<the-uuid>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"`

Then regenerate:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### Step 5: Reboot

```bash
exit
reboot -f
```

On reboot: GRUB loads kernel from EFI → initramfs asks for LUKS passphrase → root mounts.

---

## Phase 5: Post-Install Configuration

After first successful encrypted boot, login as `root`/`root`.

### Connect to Network

```bash
nmtui
```

### Add Missing Btrfs Subvolumes

```bash
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt

mkdir -p /.snapshots /var/log
```

Add to `/etc/fstab`:
```
/dev/mapper/cryptroot  /.snapshots  btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@snapshots  0 0
/dev/mapper/cryptroot  /var/log     btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@var_log    0 0
```

Mount them:
```bash
mount /.snapshots
mount /var/log
```

### Create User

```bash
useradd -m -G wheel -s /bin/zsh laenzi
passwd laenzi
EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### Set Hostname

```bash
hostnamectl set-hostname fender
echo "fender" > /etc/hostname
```

### Add Additional LUKS Passphrase

```bash
cryptsetup luksAddKey /dev/nvme0n1p5
```

### Install Packages from Chezmoi

```bash
su - laenzi
git clone https://github.com/laenzlinger/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
bash arch/setup-user.sh
```

### USB WiFi (MT7961 adapter)

The onboard Broadcom WiFi/BT chip doesn't power on (PCIe bus issue). Use a MediaTek
MT7961 USB adapter (`0e8d:7961`) instead. The `mt7921u` driver is not included in
`linux-asahi` and must be built via DKMS.

#### Build and install the driver

```bash
pacman -S --needed dkms linux-asahi-headers

# Get kernel source for the mt76 driver
cd /tmp
git clone --depth 1 --branch linux-$(uname -r | cut -d. -f1-2).y \
  https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git linux-mt76 --no-checkout
cd linux-mt76
git sparse-checkout set drivers/net/wireless/mediatek/mt76
git checkout

# Install as DKMS module
sudo cp -r drivers/net/wireless/mediatek/mt76 /usr/src/mt76-1.0
cat <<'EOF' | sudo tee /usr/src/mt76-1.0/dkms.conf
PACKAGE_NAME="mt76"
PACKAGE_VERSION="1.0"
MAKE="make -C ${kernel_source_dir} M=${dkms_tree}/${PACKAGE_NAME}/${PACKAGE_VERSION}/build CONFIG_MT76=m CONFIG_MT76_USB=m CONFIG_MT76_CONNAC_LIB=m CONFIG_MT792x_LIB=m CONFIG_MT792x_USB=m CONFIG_MT7921_COMMON=m CONFIG_MT7921U=m modules"
CLEAN="make -C ${kernel_source_dir} M=${dkms_tree}/${PACKAGE_NAME}/${PACKAGE_VERSION}/build clean"
BUILT_MODULE_NAME[0]="mt76"
BUILT_MODULE_LOCATION[0]=""
DEST_MODULE_LOCATION[0]="/updates"
BUILT_MODULE_NAME[1]="mt76-usb"
BUILT_MODULE_LOCATION[1]=""
DEST_MODULE_LOCATION[1]="/updates"
BUILT_MODULE_NAME[2]="mt76-connac-lib"
BUILT_MODULE_LOCATION[2]=""
DEST_MODULE_LOCATION[2]="/updates"
BUILT_MODULE_NAME[3]="mt792x-lib"
BUILT_MODULE_LOCATION[3]=""
DEST_MODULE_LOCATION[3]="/updates"
BUILT_MODULE_NAME[4]="mt792x-usb"
BUILT_MODULE_LOCATION[4]=""
DEST_MODULE_LOCATION[4]="/updates"
BUILT_MODULE_NAME[5]="mt7921-common"
BUILT_MODULE_LOCATION[5]="mt7921/"
DEST_MODULE_LOCATION[5]="/updates"
BUILT_MODULE_NAME[6]="mt7921u"
BUILT_MODULE_LOCATION[6]="mt7921/"
DEST_MODULE_LOCATION[6]="/updates"
AUTOINSTALL="yes"
EOF

sudo dkms add mt76/1.0
sudo dkms build mt76/1.0
sudo dkms install mt76/1.0
rm -rf /tmp/linux-mt76
```

#### Autoload and NetworkManager config

```bash
# Load module on boot
echo "mt7921u" | sudo tee /etc/modules-load.d/mt7921u.conf

# Use wpa_supplicant (IWD has association issues with mt7921)
cat <<'EOF' | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf
[device]
wifi.backend=wpa_supplicant
EOF

sudo systemctl disable iwd
sudo systemctl restart NetworkManager
```

**Note:** On major kernel upgrades, DKMS will rebuild automatically. If the build fails
due to API changes, re-clone a matching kernel source branch and update `/usr/src/mt76-1.0/`.

---

## Deleting Asahi (for reinstall)

If you need to start over, from macOS Terminal:

```bash
# Run installer to see disk info, note the Asahi APFS container disk number
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
# Quit after seeing disk info

# Delete APFS stub container (e.g. disk3)
diskutil apfs deleteContainer disk3

# Delete EFI and Linux partitions
diskutil eraseVolume free free disk0s4
diskutil eraseVolume free free disk0s5

# Do NOT resize macOS — leave free space for reinstall

# Reinstall
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

---

## Troubleshooting

### GRUB Rescue / Cannot Find Modules

GRUB modules and kernel must both be on the unencrypted EFI partition (`/boot`).
If GRUB rescue appears: `set prefix=(hd0,gpt4)/grub`, `insmod normal`, `normal`.

### Btrfs Size Mismatch After Encryption

Error: "device total_bytes should be at most X but found Y"

The btrfs filesystem was not shrunk enough before encryption. Btrfs rounds resize operations
to internal chunk boundaries, so you need a large margin. Always shrink by **256 MiB**
before using `--reduce-device-size=32M`. On a ~900GB disk this is negligible (0.03%).

### Keyboard Unreliable at GRUB Prompt

U-Boot keyboard handling on Apple Silicon can drop keystrokes. This is why we don't
use `GRUB_ENABLE_CRYPTODISK` — typing a long passphrase at the GRUB stage is unreliable.
The initramfs passphrase prompt (later in boot) has reliable keyboard input.

### Console Font Too Small (HiDPI)

At GRUB or early console, the font is tiny on Retina displays. Prefer editing configs
from the running system rather than the GRUB editor.

### Boot Chain Issues

m1n1 → U-Boot → GRUB → kernel. If boot fails:

- Hold power button → startup options → macOS
- m1n1 issues: re-run Asahi installer from macOS
- GRUB issues: mount EFI from macOS (`sudo diskutil mount disk0s4`)

### Kernel Panics

Must use `linux-asahi` — generic `linux` won't work on Apple Silicon.

### Speaker Safety

**Always** keep `speakersafetyd` enabled. Without it, speakers can be physically destroyed.

---

**Hardware:** MacBook Pro 16" M1, 1TB SSD, 32GB RAM
**Base:** Arch Linux ARM (ALARM) via Asahi
**Installation Date:** ___
