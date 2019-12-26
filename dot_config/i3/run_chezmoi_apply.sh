#!/usr/bin/env bash

if [[ -f $HOME/.config/i3/config.base ]]; then
    j4-make-config -r base16-tomorrow
fi
