#!/usr/bin/env bash
set -euo pipefail

# Cheatsheet browser using cheat and rofi
# Search across all personal cheatsheets in one view

{
  cheat -l -t personal | tail -n +2 | awk '{print $1}' | while read -r sheet; do
    echo "=== $sheet ==="
    cheat "$sheet" 2>/dev/null | awk '
      /^##/ { section = substr($0, 4); next }
      /^#/  { desc = substr($0, 3); next }
      /^$/ { next }
      { if (desc) printf "%s\t%s\n", $0, desc; else print; desc="" }
    '
    echo
  done
} | rofi -dmenu -p "cheat" -no-custom -i \
  -theme-str 'element-text { tab-stops: [200px]; }' \
  | cut -f1 | sed 's/^ *//' | wl-copy
