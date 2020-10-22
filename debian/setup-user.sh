#!/usr/bin/env bash

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Base 16 shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# No Vim Plug currently on debian
#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
#    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

~/bin/chezmoi apply

# nvim +'PlugInstall --sync' +qa
