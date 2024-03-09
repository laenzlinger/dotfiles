#!/usr/bin/env bash

PKG_LIST=~/.local/share/chezmoi/dot_config/pacman/

set -e

# install packages
sudo pacman -S --noconfirm --needed - < ${PKG_LIST}/pkglist.txt

# install aura
cd ~

git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg
sudo pacman -U --noconfirm aura-bin-*.pkg.tar.zst
cd ~
rm -rf ~/aura-bin

# install AUR packages
sudo grep -v '\-debug$' ${PKG_LIST}/foreignpkglist.txt | xargs aura --noconfirm -A
chezmoi apply

