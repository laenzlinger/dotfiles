# Configuration of my devbox

This repo contains the dotfiles managed by chezmoi


## Arch Linux (on VMWare Fusion)

### Manual steps

Followed steps in Arch Linux [installation guide](https://wiki.archlinux.org/index.php/installation_guide)

VM Settings:
* UEFI boot mode (set firmware = "efi" in VMX file)
* Virtual Disk Size 50GB
* 4 CPU
* 4096 MB RAM


```
loadkeys de_CH-latin1
```

Create partitions with `fdisk`. Create a GPT partition tablef

```
fdisk -l
TODO
```

Format partitions

```
# EFI partiation
mkfs.fat -F32 /dev/sda1
# Root / partition
mkfs.ext4 /dev/sda2
# Swap
mkswap /dev/sda3
swapon /dev/sda3
```

Mount the file systems

```
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi
```

Install base system

```
pacstrap /mnt base linux linux-firmware vi dhcpcd grub efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
vi /etc/locale.gen     # uncomment en_US.UTF-8 and de-CH.UTF-8
locale-gen
vi /etc/locale.conf    # LANG=en_US.UTF-8
vi /etc/vconsole.conf  # KEYMAP=de_CH-latin1
vi /etc/hostname       # arch
vi /etc/hosts          # see installation guid
systemctl enable dhcpcd.service
passwd
```

Install grub

```
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### List of installed packages
chezmoi apply creates list of installed packags in `.config/pacman/*.txt`

### Install all packages
To install all the packages run `dot_config/pacman/executable_install.sh` or `.config/pacman/install.sh`
