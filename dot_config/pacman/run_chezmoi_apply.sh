#!/usr/bin/env bash
set -euo pipefail

# Update package lists before backup
DIR=~/.local/share/chezmoi/dot_config/pacman/$(hostname)
mkdir -p "$DIR"

pacman -Qqen >"$DIR/pkglist.txt"
pacman -Qqem >"$DIR/foreignpkglist.txt"
echo "#optional dependencies" >"$DIR/optdeplist.txt"
comm -13 <(pacman -Qqdt | sort) <(pacman -Qqdtt | sort) >>"$DIR/optdeplist.txt"

# systemd services
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' >"$DIR/enabled_units.txt"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
systemctl --user list-unit-files --state=enabled --no-legend | awk '{print $1}' >"$DIR/enabled_user_units.txt"
