#!/usr/bin/env bash
set -euo pipefail

command -v rofi >/dev/null || exit 1

BG="$HOME/.config/sway/resources/background.jpg"

choice=$(printf " Lock\n Logout\n⏾ Suspend\n Reboot\n Shutdown" | rofi -dmenu -i -p "Power" -theme-str 'listview { lines: 5; }')

case "$choice" in
  *Lock)     swaylock -k -l -F -f --image "$BG" ;;
  *Logout|*Suspend|*Reboot|*Shutdown)
    if [[ "$(~/.config/waybar/scripts/restic-status.sh)" == *'"class": "running"'* ]]; then
      confirm=$(printf "Yes, stop backup\nNo, cancel" | rofi -dmenu -i -p "⚠ Backup running!")
      [[ "$confirm" != "Yes, stop backup" ]] && exit 0
    fi
    case "$choice" in
      *Logout)   uwsm stop ;;
      *Suspend)  systemctl suspend ;;
      *Reboot)   systemctl reboot ;;
      *Shutdown) systemctl poweroff ;;
    esac
    ;;
esac
