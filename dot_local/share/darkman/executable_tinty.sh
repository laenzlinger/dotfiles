#!/usr/bin/env bash
set -euo pipefail

case "$1" in
dark) THEME=base16-darktooth ;;
light) THEME=base16-gruvbox-light-medium ;;
esac

SWAYSOCK=$(find /run/user/"$(id -u)" -name 'sway-ipc.*.sock' -print -quit 2>/dev/null)
if [[ -z "$SWAYSOCK" ]]; then
  echo "tinty.sh: No sway socket found, skipping" >&2
  exit 0
fi
export SWAYSOCK
/usr/bin/tinty apply "$THEME"
