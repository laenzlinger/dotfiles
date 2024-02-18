#!/usr/bin/env bash

# install packages
sudo pacman -S --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

echo "setup yay"

chezmoi apply

