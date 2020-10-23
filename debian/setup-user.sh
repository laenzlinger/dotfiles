#!/usr/bin/env bash

git config --global http.proxy $https_proxy

# oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
~/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install -f

# Base 16 shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# No Vim Plug currently on debian
#curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
#    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

~/bin/chezmoi apply

# nvim +'PlugInstall --sync' +qa
