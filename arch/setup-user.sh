#!/usr/bin/env bash
set -euo pipefail

PKG_LIST=~/.local/share/chezmoi/dot_config/pacman/$(hostname)

# install official packages (skip failures)
while IFS= read -r pkg; do
  sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null || echo "SKIPPED: $pkg"
done < <(comm -12 <(pacman -Slq | sort) <(sort "${PKG_LIST}/pkglist.txt"))

# install yay
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  rm -rf /tmp/yay
fi

# initialize rust toolchain (needed for some AUR builds)
rustup default stable

# install AUR packages
grep -v '\-debug$' "${PKG_LIST}/foreignpkglist.txt" | \
  grep -v '^yay$' | \
  yay -S --noconfirm --needed -

chezmoi apply
