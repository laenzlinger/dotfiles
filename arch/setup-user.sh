#!/usr/bin/env bash

# install packages
sudo pacman -S --needed - < $HOME/.local/share/chezmoi/dot_config/pacman/pkglist.txt

# install aur packages
mkdir -p $HOME/src/aur
pushd $HOME/src/aur
git clone https://aur.archlinux.org/nerd-fonts-meslo.git
cd nerd-fonts-meslo
makepkg -si --noconfirm
popd

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# Vim Plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

chezmoi apply

nvim +'PlugInstall --sync' +qa
