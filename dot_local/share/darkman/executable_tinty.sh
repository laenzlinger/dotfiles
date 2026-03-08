#!/usr/bin/env bash
set -euo pipefail

case "$1" in
dark) THEME=base16-darktooth ;;
light) THEME=base16-solarized-light ;;
esac

/usr/bin/tinty apply "$THEME"
