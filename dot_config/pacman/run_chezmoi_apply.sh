#!/usr/bin/env bash

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DIR=~/.local/share/chezmoi/dot_config/pacman

pacman -Qqen >$DIR/pkglist.txt
pacman -Qqem >$DIR/foreignpkglist.txt
echo "#optional dependencies" >$DIR/optdeplist.txt
comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) >>$DIR/optdeplist.txt

# systemd services
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' >$DIR/enabled_units.txt
systemctl --user list-unit-files --state=enabled --no-legend | awk '{print $1}' >$DIR/enabled_user_units.txt
