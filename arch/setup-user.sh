#!/usr/bin/env bash

# install packages
sudo pacman -S --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install yay

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si


chezmoi apply

