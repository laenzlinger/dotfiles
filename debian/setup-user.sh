#!/usr/bin/env bash

git config --global http.proxy $https_proxy

# oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
~/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install -f

# Base 16 shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

~/bin/chezmoi apply

# nvim +'PlugInstall --sync' +qa
