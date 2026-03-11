#!/usr/bin/env bash
set -euo pipefail

command -v rofi >/dev/null || exit 1

BG="$HOME/.config/sway/resources/background.jpg"

choice=$(printf " Lock\n Logout\n⏾ Suspend\n Reboot\n Shutdown" | rofi -dmenu -i -p "Power" -theme-str 'listview { lines: 5; }')

case "$choice" in
  *Lock)     swaylock -k -l -F -f --image "$BG" ;;
  *Logout)   uwsm stop ;;
  *Suspend)  systemctl suspend ;;
  *Reboot)   systemctl reboot ;;
  *Shutdown) systemctl poweroff ;;
esac
