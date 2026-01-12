#!/usr/bin/env sh

# trigger a small, passive popup dialog to inform the user about darkman's activity
# reference https://wiki.archlinux.org/title/Desktop_notifications#Usage_in_programming
#

ICON_WORKAROUND="/usr/share/icons/Papirus/48x48/status"

case "$1" in
dark) ICON=$ICON_WORKAROUND/weather-clear-night.svg ;;
light) ICON=$ICON_WORKAROUND/weather-clear.svg ;;
esac

notify-send --app-name="darkman" --urgency=low --icon="$ICON" "darkman" "switching to $1 mode"
