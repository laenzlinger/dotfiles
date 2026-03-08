#!/usr/bin/env bash
set -euo pipefail

# Control keyboard backlight based on mode

case "$1" in
dark) BRIGHTNESS=2 ;;  # Activate keyboard backlight in dark mode
light) BRIGHTNESS=0 ;; # Disable keyboard backlight in light mode
esac

dbus-send --system --type=method_call --dest="org.freedesktop.UPower" "/org/freedesktop/UPower/KbdBacklight" "org.freedesktop.UPower.KbdBacklight.SetBrightness" "int32:$BRIGHTNESS"
