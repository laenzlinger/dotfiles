# Arch Linux Installation Guide - ThinkPad X1 Carbon Gen 12

**Hardware:** Lenovo ThinkPad X1 Carbon Gen 12  
**Specs:** 1TB NVMe SSD, 32GB RAM, Intel i7-1360P  
**Configuration:** LUKS encryption, btrfs with subvolumes, systemd-boot, full backup restoration

---

## 1. Pre-Installation Setup

### 1.1 Boot from Arch ISO

Boot from the Arch Linux USB installation media. The system should boot into the live environment.

### 1.2 Verify Keyboard Layout

The default US keyboard layout should already be loaded:

```bash
# Verify current layout (should show 'us')
localectl status
```

### 1.3 Connect to Network

**For Ethernet:** Should connect automatically.

**For WiFi:**

```bash
iwctl
# Inside iwctl prompt:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <SSID>
# Enter password when prompted
exit
```

Verify connectivity:

```bash
ping -c 3 archlinux.org
```

### 1.4 Update System Clock

```bash
timedatectl set-ntp true
timedatectl status
```

### 1.5 Mount External USB Backup Drive

Identify the USB drive:

```bash
lsblk
```

Mount the USB drive (adjust device name as needed):

```bash
mkdir -p /mnt/backup
mount /dev/sdX1 /mnt/backup  # Replace sdX1 with your USB partition
ls /mnt/backup/gibson-home   # Verify backup directory exists
```

---

## 2. Disk Partitioning and LUKS Encryption

### 2.1 Identify NVMe Device

```bash
lsblk
# Your NVMe drive should be /dev/nvme0n1
```

### 2.2 Wipe Existing Partitions (Optional but Recommended)

```bash
# WARNING: This will destroy all data on the drive
wipefs -a /dev/nvme0n1
```

### 2.3 Create Partition Table

```bash
gdisk /dev/nvme0n1
```

Inside gdisk:

```
o     # Create new GPT partition table
y     # Confirm

# Create EFI partition (1GB)
n     # New partition
1     # Partition number
      # Default first sector
+1G   # Size
ef00  # EFI System partition type

# Create LUKS partition (remaining space)
n     # New partition
2     # Partition number
      # Default first sector
      # Default last sector (use remaining space)
8309  # Linux LUKS partition type

w     # Write changes
y     # Confirm
```

### 2.4 Format EFI Partition

```bash
mkfs.fat -F32 /dev/nvme0n1p1
```

### 2.5 Setup LUKS Encryption

```bash
# Format partition with LUKS
cryptsetup luksFormat /dev/nvme0n1p2
# Type 'YES' (uppercase) and enter a strong passphrase

# Open the encrypted partition
cryptsetup open /dev/nvme0n1p2 cryptroot
# Enter your passphrase
```

---

## 3. Btrfs Filesystem and Subvolumes

### 3.1 Create Btrfs Filesystem

```bash
mkfs.btrfs /dev/mapper/cryptroot
```

### 3.2 Mount and Create Subvolumes

```bash
# Mount the btrfs filesystem
mount /dev/mapper/cryptroot /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log

# Unmount to remount with proper subvolumes
umount /mnt
```

### 3.3 Mount Subvolumes with Options

```bash
# Mount root subvolume
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt

# Create mount points
mkdir -p /mnt/{home,boot,.snapshots,var/log}

# Mount other subvolumes
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress=zstd:1,space_cache=v2,subvol=@var_log /dev/mapper/cryptroot /mnt/var/log

# Mount EFI partition
mount /dev/nvme0n1p1 /mnt/boot
```

Verify mount structure:

```bash
lsblk
mount | grep /mnt
```

---

## 4. Base System Installation

### 4.1 Update Mirror List (Optional)

```bash
# Backup original mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Use reflector to get fastest mirrors
reflector --country Switzerland,Germany,France --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### 4.2 Install Base System

```bash
pacstrap -K /mnt base linux linux-firmware intel-ucode btrfs-progs \
    vim networkmanager sudo git base-devel
```

---

## 5. System Configuration

### 5.1 Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab

# Verify fstab
cat /mnt/etc/fstab
```

### 5.2 Chroot into New System

```bash
arch-chroot /mnt
```

### 5.3 Set Timezone

```bash
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc
```

### 5.4 Configure Locale

```bash
# Edit locale.gen
vim /etc/locale.gen
# Uncomment: en_US.UTF-8 UTF-8

# Generate locale
locale-gen

# Set locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### 5.5 Set Hostname

```bash
echo "gibson" > /etc/hostname

# Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   gibson.home gibson
EOF
```

### 5.6 Set Root Password

```bash
passwd
# Enter a strong root password
```

### 5.7 Configure mkinitcpio for LUKS

```bash
# Edit mkinitcpio.conf
vim /etc/mkinitcpio.conf
```

Modify the HOOKS line to include `encrypt` before `filesystems`:

```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

Regenerate initramfs:

```bash
mkinitcpio -P
```

---

## 6. Bootloader Installation (systemd-boot)

### 6.1 Install systemd-boot

```bash
bootctl install
```

### 6.2 Get UUID of Encrypted Partition

```bash
blkid /dev/nvme0n1p2
# Note the UUID value
```

### 6.3 Create Loader Configuration

```bash
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF
```

### 6.4 Create Boot Entry

```bash
# Get the UUID from the previous step and replace <UUID> below
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=<UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet
EOF
```

**Important:** Replace `<UUID>` with the actual UUID from step 6.2.

### 6.5 Create Fallback Entry

```bash
cat > /boot/loader/entries/arch-fallback.conf << EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options cryptdevice=UUID=<UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
EOF
```

**Important:** Replace `<UUID>` with the actual UUID.

---

## 7. Swapfile Configuration (32GB with Hibernation)

### 7.1 Create Swapfile

```bash
# Create swapfile with no CoW attribute for btrfs
truncate -s 0 /swapfile
chattr +C /swapfile
btrfs property set /swapfile compression none

# Allocate 32GB
dd if=/dev/zero of=/swapfile bs=1M count=32768 status=progress

# Set permissions
chmod 600 /swapfile

# Format as swap
mkswap /swapfile

# Enable swap
swapon /swapfile
```

### 7.2 Add Swapfile to Fstab

```bash
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

### 7.3 Configure Hibernation

Get swapfile offset:

```bash
# Install btrfs-progs if not already installed
pacman -S btrfs-progs

# Get physical offset
btrfs inspect-internal map-swapfile -r /swapfile
# Note this number
```

Update mkinitcpio hooks:

```bash
vim /etc/mkinitcpio.conf
```

Add `resume` hook after `filesystems`:

```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems resume fsck)
```

Regenerate initramfs:

```bash
mkinitcpio -P
```

Update bootloader entries with resume parameters:

```bash
vim /boot/loader/entries/arch.conf
```

Add to the options line (replace `<OFFSET>` with the value from btrfs inspect-internal):

```
options cryptdevice=UUID=<UUID>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ resume=/dev/mapper/cryptroot resume_offset=<OFFSET> rw quiet
```

Do the same for arch-fallback.conf.

---

## 8. Restic Backup Restoration - Packages

### 8.1 Enable NetworkManager

```bash
systemctl enable NetworkManager
```

### 8.2 Create User Account

```bash
useradd -m -G wheel -s /bin/bash laenzi
passwd laenzi
# Enter password for laenzi

# Enable sudo for wheel group
EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### 8.3 Mount Backup Drive (if not already mounted)

Exit chroot temporarily:

```bash
exit
```

If backup drive is not mounted:

```bash
mkdir -p /mnt/backup
mount /dev/sdX1 /mnt/backup  # Adjust device name
```

Re-enter chroot with backup access:

```bash
arch-chroot /mnt
mkdir -p /mnt/backup
mount --bind /mnt/backup /mnt/backup  # If needed
```

Or mount from within chroot:

```bash
# From within chroot
mkdir -p /backup
# Exit chroot, mount backup to /mnt/backup, re-enter chroot
```

**Simpler approach - work from live environment:**

Exit chroot:

```bash
exit
```

### 8.4 Install Restic in Live Environment

```bash
pacman -Sy restic
```

### 8.5 Extract Package Lists from Backup

```bash
# Set restic repository
export RESTIC_REPOSITORY=/mnt/backup/gibson-home

# Retrieve password from your password manager and set it
export RESTIC_PASSWORD="your-password-here"

# List snapshots
restic snapshots

# Extract package lists
mkdir -p /tmp/package-lists
restic restore latest --target /tmp/package-lists --include /home/laenzi/.local/share/chezmoi/dot_config/pacman/pkglist.txt
restic restore latest --target /tmp/package-lists --include /home/laenzi/.local/share/chezmoi/dot_config/pacman/foreignpkglist.txt

# Find the extracted files
find /tmp/package-lists -name "pkglist.txt"
find /tmp/package-lists -name "foreignpkglist.txt"
```

### 8.6 Install Official Packages

```bash
# Copy package list to accessible location
cp /tmp/package-lists/home/laenzi/.local/share/chezmoi/dot_config/pacman/pkglist.txt /mnt/root/

# Install packages from list
arch-chroot /mnt pacman -S --needed - < /mnt/root/pkglist.txt
```

### 8.7 Install Yay (AUR Helper)

```bash
arch-chroot /mnt
su - laenzi
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
exit  # Back to root
```

### 8.8 Install AUR Packages

```bash
# Copy foreign package list
cp /tmp/package-lists/home/laenzi/.local/share/chezmoi/dot_config/pacman/foreignpkglist.txt /mnt/home/laenzi/

# Install AUR packages as laenzi user
arch-chroot /mnt su - laenzi -c "yay -S --needed - < /home/laenzi/foreignpkglist.txt"
```

---

## 9. Restic Backup Restoration - User Data and Configs

### 9.1 Restore /home/laenzi

From live environment (outside chroot):

```bash
export RESTIC_REPOSITORY=/mnt/backup/gibson-home
export RESTIC_PASSWORD="your-password-here"

# Restore /home/laenzi
restic restore latest --target /mnt --include /home/laenzi
```

### 9.2 Restore /root

```bash
restic restore latest --target /mnt --include /root
```

### 9.3 Restore /etc (with caution)

```bash
# Restore to temporary location first
mkdir -p /mnt/root/etc-backup
restic restore latest --target /mnt/root/etc-backup --include /etc
```

**Note:** Do NOT blindly overwrite /etc. You'll manually merge configs in the next section.

### 9.4 Restore /boot Configs

```bash
# Restore boot configs (not bootloader itself)
mkdir -p /mnt/root/boot-backup
restic restore latest --target /mnt/root/boot-backup --include /boot
```

### 9.5 Fix Permissions

```bash
arch-chroot /mnt
chown -R laenzi:laenzi /home/laenzi
chown -R root:root /root
```

---

## 10. Post-Installation Cleanup and Verification

### 10.1 Review and Merge /etc Configs

**Critical files to NOT overwrite from backup:**

- `/etc/fstab` - Keep the newly generated one
- `/etc/mkinitcpio.conf` - Keep the one configured for LUKS
- `/etc/crypttab` - Not needed with systemd-boot + kernel parameters
- `/etc/hostname` - Already set
- `/etc/hosts` - Already set
- `/etc/locale.conf` - Already set
- `/etc/locale.gen` - Already configured

**Files you may want to restore from backup:**

- Network configurations (if any custom settings)
- Custom service configurations
- Application-specific configs in /etc

```bash
# From within chroot
cd /root/etc-backup/etc

# Review what's in the backup
ls -la

# Selectively copy configs you need, for example:
# cp -r /root/etc-backup/etc/some-custom-config /etc/

# Review differences for important files
diff /etc/pacman.conf /root/etc-backup/etc/pacman.conf
# Merge any custom settings manually
```

### 10.2 Verify User Accounts

```bash
# Check that laenzi user exists and has correct groups
id laenzi
groups laenzi

# Ensure laenzi is in wheel group for sudo
usermod -aG wheel laenzi
```

### 10.3 Enable Essential Services

```bash
# NetworkManager should already be enabled, verify:
systemctl enable NetworkManager

# Enable other services as needed from your backup
# Check what was enabled in your old system:
# ls /root/etc-backup/etc/systemd/system/*.wants/
```

### 10.4 Verify Bootloader Configuration

```bash
# Double-check boot entries have correct UUIDs
cat /boot/loader/entries/arch.conf
cat /boot/loader/entries/arch-fallback.conf

# Verify UUID matches
blkid /dev/nvme0n1p2
```

### 10.5 Final Checks

```bash
# Verify fstab
cat /etc/fstab

# Verify mkinitcpio.conf has correct hooks
cat /etc/mkinitcpio.conf | grep HOOKS

# Verify locale
locale

# Verify timezone
timedatectl status
```

### 10.6 Exit and Unmount

```bash
# Exit chroot
exit

# Unmount all partitions
umount -R /mnt
umount /mnt/backup

# Close encrypted partition
cryptsetup close cryptroot

# Reboot
reboot
```

---

## 11. Post-Reboot Verification

After rebooting, you should be prompted for your LUKS passphrase, then boot into your new system.

### 11.1 Login and Verify

```bash
# Login as laenzi

# Check network connectivity
ping -c 3 archlinux.org

# If WiFi, connect using nmcli or nmtui
nmtui

# Verify swap is active
swapon --show
free -h

# Verify btrfs subvolumes
sudo btrfs subvolume list /

# Check disk usage
df -h

# Verify all packages are installed
pacman -Q | wc -l
```

### 11.2 Test Hibernation (Optional)

```bash
# Test hibernation
sudo systemctl hibernate

# System should hibernate and resume with all state preserved
```

### 11.3 Additional Configuration

- Configure any remaining services from your backup
- Set up any custom configurations
- Verify all applications work as expected
- Consider creating a snapshot of the fresh installation

---

## Troubleshooting

### Boot Issues

If system doesn't boot:

1. Boot from Arch ISO again
2. Decrypt and mount partitions:

   ```bash
   cryptsetup open /dev/nvme0n1p2 cryptroot
   mount -o subvol=@ /dev/mapper/cryptroot /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   arch-chroot /mnt
   ```

3. Check bootloader configuration
4. Regenerate initramfs: `mkinitcpio -P`

### Network Issues

```bash
# Start NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Use nmtui for easy network configuration
nmtui
```

### Package Installation Failures

If some packages fail to install:

- Check if they've been renamed or removed from repositories
- Try installing them individually to identify issues
- Check AUR for replacements

---

## Notes

- This guide assumes a clean installation. Adjust as needed for your specific requirements.
- Always keep your LUKS passphrase secure and backed up separately.
- Consider setting up regular btrfs snapshots using snapper or timeshift.
- The restic backup password should be stored securely in your password manager.
- Review all restored /etc configs carefully to avoid conflicts with the fresh installation.

---

**Installation Date:** February 2026  
**System:** Lenovo ThinkPad X1 Carbon Gen 12  
**Arch Linux Version:** Rolling Release
