#!/bin/bash

# Define the new theme state
NEW_STATE=$1 # Pass "dark" or "light" as an argument
ICON_THEME="Papirius"
DARK_THEME="darker"
LIGHT_THEME="simple"

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=$(ls $XDG_RUNTIME_DIR/wayland-* 2>/dev/null | head -n 1 | xargs basename)
export QT_QPA_PLATFORM="wayland"

# Path to config files
QT6_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"
QT5_CONFIG="$HOME/.config/qt5ct/qt5ct.conf"

if [ "$NEW_STATE" == "dark" ]; then
  /usr/sbin/kvantummanager --set "MateriaDark"

  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt6ct\/colors\/$DARK_THEME.conf/" "$QT6_CONFIG"
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt5ct\/colors\/$DARK_THEME.conf/" "$QT5_CONFIG"

  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Dark/" "$QT6_CONFIG"
  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Dark/" "$QT5_CONFIG"
else
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt6ct\/colors\/$LIGHT_THEME.conf/" "$QT6_CONFIG"
  sed -i "s/color_scheme_path=.*/color_scheme_path=\/usr\/share\/qt5ct\/colors\/$LIGHT_THEME.conf/" "$QT5_CONFIG"

  /usr/sbin/kvantummanager --set "MateriaLight"

  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Light/" "$QT6_CONFIG"
  sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME-Light/" "$QT5_CONFIG"
fi
touch "QT5_CONFIG"
touch "QT6_CONFIG"

# Tell Sway/Wayland apps the environment has changed
systemctl --user set-environment QT_QPA_PLATFORMTHEME=qt5ct
#systemctl --user set-environment QT_STYLE_OVERRIDE=kvantum
# Crucial for Wayland: Import updated environment to D-Bus
dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME
