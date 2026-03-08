#!/usr/bin/env bash
set -euo pipefail

NEW_STATE=$1
ICON_THEME="Papirus"
DARK_THEME="darker"
LIGHT_THEME="simple"

XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_RUNTIME_DIR
WAYLAND_DISPLAY=$(find "$XDG_RUNTIME_DIR" -maxdepth 1 -name 'wayland-*' 2>/dev/null | head -n 1 | xargs basename)
export WAYLAND_DISPLAY
export QT_QPA_PLATFORM="wayland"

QT6_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"
QT5_CONFIG="$HOME/.config/qt5ct/qt5ct.conf"

if [[ "$NEW_STATE" == "dark" ]]; then
  kvantummanager --set "MateriaDark"

  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt6ct\/colors\/$DARK_THEME.conf/" "$QT6_CONFIG"
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt5ct\/colors\/$DARK_THEME.conf/" "$QT5_CONFIG"

  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Dark/" "$QT6_CONFIG"
  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Dark/" "$QT5_CONFIG"
else
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt6ct\/colors\/$LIGHT_THEME.conf/" "$QT6_CONFIG"
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt5ct\/colors\/$LIGHT_THEME.conf/" "$QT5_CONFIG"

  kvantummanager --set "MateriaLight"

  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Light/" "$QT6_CONFIG"
  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Light/" "$QT5_CONFIG"
fi
touch "$QT5_CONFIG"
touch "$QT6_CONFIG"

systemctl --user set-environment QT_QPA_PLATFORMTHEME=qt5ct
dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME
