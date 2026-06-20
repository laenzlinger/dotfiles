#!/usr/bin/env bash
set -uo pipefail

command -v rofi >/dev/null || exit 1

BG="$HOME/.config/sway/resources/background.jpg"

choice=$(printf " Lock\n Logout\n⏾ Suspend\n Reboot\n Shutdown" | rofi -dmenu -i -p "Power" -theme-str 'listview { lines: 5; }')

case "$choice" in
  *Lock)     swaylock -k -l -F -f --image "$BG" ;;
  *Logout|*Suspend|*Reboot|*Shutdown)
    if systemctl is-active --quiet resticprofile-backup@profile-rotating-backup.service; then
      confirm=$(printf "No, cancel\nYes, stop backup" | rofi -dmenu -i -p "⚠ Backup running!")
      [[ "$confirm" != "Yes, stop backup" ]] && exit 0
    fi
    case "$choice" in
      *Logout)   uwsm stop ;;
      *Suspend)  systemctl suspend --check-inhibitors=yes ;;
      *Reboot)   systemctl reboot --check-inhibitors=yes ;;
      *Shutdown) systemctl poweroff --check-inhibitors=yes ;;
    esac
    ;;
esac
