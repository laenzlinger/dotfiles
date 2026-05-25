#!/usr/bin/env bash
set -euo pipefail

PKG_LIST=~/.local/share/chezmoi/dot_config/pacman

# install official packages (skip unavailable)
comm -12 <(pacman -Slq | sort) <(sort "${PKG_LIST}/pkglist.txt") | \
  sudo pacman -S --noconfirm --needed -

# install yay
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  rm -rf /tmp/yay
fi

# install AUR packages
grep -v '\-debug$' "${PKG_LIST}/foreignpkglist.txt" | \
  grep -v '^yay$' | \
  yay -S --noconfirm --needed -

chezmoi apply
