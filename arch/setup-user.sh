#!/usr/bin/env bash

set -e

# install packages
sudo pacman -S --noconfirm --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install aura
cd ~

git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg
sudo pacman -U aura
cd ~
rm ~/aura-bin

chezmoi apply

