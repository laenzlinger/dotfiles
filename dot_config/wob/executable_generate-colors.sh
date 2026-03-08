#!/usr/bin/env bash
# Generate wob colors from waybar colors.css (base16)
set -euo pipefail
src=~/.config/waybar/colors.css
get() { sed -n "s/@define-color $1 #\(.*\);/\1/p" "$src"; }

cat > ~/.config/wob/wob-colors.ini <<EOF
border_color = $(get base05)
background_color = $(get base00)
bar_color = $(get base09)
overflow_bar_color = $(get base08)
overflow_background_color = $(get base00)
overflow_border_color = $(get base05)
EOF

cat > ~/.config/wob/wob-base.ini <<EOF
[style.MUTED]
bar_color = $(get base03)
EOF

cat ~/.config/wob/wob-colors.ini ~/.config/wob/wob-base.ini > ~/.config/wob/wob.ini
systemctl --user restart wob
