#!/usr/bin/env bash
set -euo pipefail

PKG_LIST=~/.local/share/chezmoi/dot_config/pacman

# install official packages
# shellcheck disable=SC2024
sudo pacman -S --noconfirm --needed - < "${PKG_LIST}/pkglist.txt"

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
