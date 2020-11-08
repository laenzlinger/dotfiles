#!/usr/bin/env bash

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR=~/.local/share/chezmoi/dot_config/homebrew

cd $DIR
brew bundle dump --force --no-upgrade
