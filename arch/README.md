# Arch Linux on Lenovo ThinkPad X1 Carbon

## Hardware Information

The computer is a Lenovo ThinkPad X1 Carbon Gen 12
It has a 1TB NVMe SSD, 32GB RAM, Intel i7-1360P CPU.

I have a standard US keyboard layout.

## Setup

I want to install a modern and secure Arch Linux on this machine with the following specifications:

I live in Zurich, Switzerland, so please set the timezone accordingly.
My default locale should be en_US.UTF-8

I want to use btrfs with subvolumes, systemd-boot as the bootloader, and enable full disk encryption
with LUKS. I currently have separate partitions for /home/laenzi and root

Since I have an intel processor, please add the microcode installation in mkinitcpio.

## Backup Information

I have a backup of my data, so I don't mind if the installation process involves formatting the
disk. The backup is done with restic. I have a backup for /home/laenzi /etc /boot /root

The backup is stored on an external USB drive in a directory called `gibson-home`

The backup includes exports of the packages installed: These files are created with the following
script

```bash
#!/usr/bin/env bash

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR=~/.local/share/chezmoi/dot_config/pacman

pacman -Qqen > $DIR/pkglist.txt
pacman -Qqem > $DIR/foreignpkglist.txt
echo "#optional dependencies" > $DIR/optdeplist.txt
comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) >> $DIR/optdeplist.txt

```

I am using yay as my AUR helper.

## Instructions

Please create a detailed step-by-step installation guide for this setup. Include partitioning,
formatting, restoring from backup, and configuring the system with the specified requirements.
I want the same packages and the same foreign packages installed as in my backup.

Please create a downloadable markdown file with the complete instructions.
