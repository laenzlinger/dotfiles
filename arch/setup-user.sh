#!/usr/bin/env bash

function install-aur {
  pkg=$1
  pushd ~/src/aur
  git clone https://aur.archlinux.org/$pkg.git
  cd $pkg
  makepkg -si --noconfirm
  popd
}

# install packages
sudo pacman -S --needed - < ~/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install aur packages
install-aur nerd-fonts-meslo
install-aur cloudfoundry-cli
install-aur google-cloud-sdk
install-aur velero-bin

# oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Base 16 shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

chezmoi apply

