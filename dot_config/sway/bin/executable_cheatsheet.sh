#!/usr/bin/env bash
set -euo pipefail

# Cheatsheet browser: pick a sheet, then search within it

sheet=$(cheat -l -t personal | tail -n +2 | awk '{print $1}' \
  | rofi -dmenu -p "cheatsheet" -no-custom -i)

[[ -z "$sheet" ]] && exit 0

cheat "$sheet" 2>/dev/null | awk '
  /^##/ { section = substr($0, 4); next }
  /^#/  { desc = substr($0, 3); next }
  /^$/ { next }
  { if (desc) printf "%s\t%s\n", $0, desc; else print; desc="" }
' | rofi -dmenu -p "$sheet" -no-custom -i \
  -theme-str 'element-text { tab-stops: [200px]; }' \
  | cut -f1 | sed 's/^ *//' | wl-copy
