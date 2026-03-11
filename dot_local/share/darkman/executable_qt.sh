#!/usr/bin/env bash
set -euo pipefail

NEW_STATE=$1
ICON_THEME="Papirus"
DARK_THEME="darker"
LIGHT_THEME="simple"

XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_RUNTIME_DIR
WAYLAND_SOCKET=$(find "$XDG_RUNTIME_DIR" -maxdepth 1 -name 'wayland-*' ! -name '*.lock' -print -quit 2>/dev/null)
if [[ -z "$WAYLAND_SOCKET" ]]; then
  echo "qt.sh: No wayland socket found, skipping" >&2
  exit 0
fi
WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
export WAYLAND_DISPLAY
export QT_QPA_PLATFORM="wayland"

QT_CONFIGS=(
  "$HOME/.config/qt5ct/qt5ct.conf qt5ct"
  "$HOME/.config/qt6ct/qt6ct.conf qt6ct"
)

if [[ "$NEW_STATE" == "dark" ]]; then
  kvantummanager --set "MateriaDark"
  COLOR_SCHEME="$DARK_THEME"
  ICON="$ICON_THEME-Dark"
else
  kvantummanager --set "MateriaLight"
  COLOR_SCHEME="$LIGHT_THEME"
  ICON="$ICON_THEME-Light"
fi

for entry in "${QT_CONFIGS[@]}"; do
  read -r conf name <<< "$entry"
  sed -i "s|color_scheme_path=.*|color_scheme_path=/usr/share/$name/colors/$COLOR_SCHEME.conf|" "$conf"
  sed -i "s/icon_theme=.*/icon_theme=$ICON/" "$conf"
  touch "$conf"
done

systemctl --user set-environment QT_QPA_PLATFORMTHEME=qt5ct
dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME
