#!/usr/bin/env bash
set -euo pipefail

case "$1" in
dark) THEME=base16-darktooth ;;
light) THEME=base16-solarized-light ;;
esac

SWAYSOCK=$(find /run/user/"$(id -u)" -name 'sway-ipc.*.sock' 2>/dev/null | head -1)
export SWAYSOCK
/usr/bin/tinty apply "$THEME"
