#!/usr/bin/env bash
set -euo pipefail
sheet=$(cheat -l -t personal | tail -n +2 | awk '{print $1}' | rofi -dmenu -i -p "Cheatsheet")
[ -n "$sheet" ] || exit 0
cheat "$sheet" | awk '
    /^##/ { section = substr($0, 4); next }
    /^#/  { desc = substr($0, 3); next }
    /^$/ { next }
    { if (desc) printf "%s\t%s\n", $0, desc; else print; desc="" }
' | rofi -dmenu -i -p "$sheet" -eh 1 -sep '\n' \
    -theme-str 'element-text { tab-stops: [200px]; }'
