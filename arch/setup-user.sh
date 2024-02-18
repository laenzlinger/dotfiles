#!/usr/bin/env bash

# install packages
sudo pacman -S --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install yay

cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
rm -rf ~/yay


chezmoi apply

