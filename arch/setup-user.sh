#!/usr/bin/env bash

set -e

# install packages
sudo pacman -S --noconfirm --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install yay
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
rm -rf ~/yay

chezmoi apply

