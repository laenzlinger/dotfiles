#!/usr/bin/env bash

if [ -n "$https_proxy" ]; then
  git config --global http.proxy "$https_proxy"
fi

# antidote (managed by chezmoi external)
# Base 16 shell (deprecated - now using tinty)

~/bin/chezmoi apply
