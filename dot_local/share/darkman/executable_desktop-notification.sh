#!/usr/bin/env bash
set -euo pipefail

ICON_WORKAROUND="/usr/share/icons/Papirus/48x48/status"

case "$1" in
dark) ICON=$ICON_WORKAROUND/weather-clear-night.svg ;;
light) ICON=$ICON_WORKAROUND/weather-clear.svg ;;
esac

notify-send --app-name="darkman" --urgency=low --icon="$ICON" "darkman" "switching to $1 mode"
