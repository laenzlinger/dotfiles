#!/usr/bin/env bash


echo "Create partition table"

sfdisk -f /dev/sda <<EOT
label: gpt
label-id: C8F7AF60-8368-9643-AD1C-85CFE21890F3
device: /dev/sda
unit: sectors
first-lba: 2048
last-lba: 104857566

/dev/sda1 : start=        2048, size=     1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=DE315412-076D-BE41-BEA0-1E7E6D513038
/dev/sda2 : start=     1050624, size=    94371840, type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709, uuid=044839E9-2B3C-BA4E-8301-741D88FB2CEA
/dev/sda3 : start=    95422464, size=     9435103, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, uuid=BF769C53-979D-7E40-87C8-5E45426F43AF
EOT

echo "Format the disk partitions"

# EFI partiation
mkfs.fat -F32 /dev/sda1

# Root partition
mkfs.ext4 /dev/sda2

# Swap partition
mkswap /dev/sda3
swapon /dev/sda3

echo "Mount the file systems"
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi

echo "Unstall base system"
cat <<EOT > /etc/pacman.d/mirrorlist
Server = https://mirror.puzzle.ch/archlinux/\$repo/os/\$arch
Server = https://pkg.adfinis-sygroup.ch/archlinux/\$repo/os/\$arch
Server = https://mirror.init7.net/archlinux/\$repo/os/\$arch
Server = https://mirror.ungleich.ch/mirror/packages/archlinux/\$repo/os/\$arch
Server = https://mirror.netcologne.de/archlinux/\$repo/os/\$arch
Server = http://ftp.halifax.rwth-aachen.de/archlinux/\$repo/os/\$arch
EOT

pacstrap /mnt base linux linux-firmware vi dhcpcd grub efibootmgr open-vm-tools sudo

echo "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOT
echo "Set Time Zone"
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

echo "Set Locale"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_CH.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Set Keymap"
echo "KEYMAP=de_CH-latin1" > /etc/vconsole.conf

echo "Set Hostname"
echo "arch" > /etc/hostname
echo "127.0.0.1	localhost" > /etc/hosts
echo "::1		localhost" >> /etc/hosts

echo "Install grub"
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Preload vmware modules"
sed -i 's/MODULES=.*/MODULES=(vmhgfs,vmxnet)/' /etc/mkinitcpio.conf

echo "Enable Services"
systemctl enable dhcpcd.service
systemctl enable vmtoolsd.service
systemctl enable vmware-vmblock-fuse.service

echo "Configure Xorg keyboard"
mkdir -p /etc/X11/xorg.conf.d
echo 'Section "InputClass"' > /etc/X11/xorg.conf.d/00-keyboard.conf
echo '   Identifier "system-keyboard"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '   MatchIsKeyboard "on"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '   Option "XkbLayout" "ch"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '   Option "XkbModel" "macintosh"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo '   Option "XkbVariant" "de"' >> /etc/X11/xorg.conf.d/00-keyboard.conf
echo 'endSection' >> /etc/X11/xorg.conf.d/00-keyboard.conf
EOT
