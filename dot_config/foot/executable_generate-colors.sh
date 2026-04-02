#!/usr/bin/env bash
set -euo pipefail
command -v sed >/dev/null || exit 1

WAYBAR_CSS="$HOME/.config/waybar/colors.css"
OUT="$HOME/.config/foot/colors.ini"

[ -f "$WAYBAR_CSS" ] || exit 0

get() { sed -n "s/.*$1 #\([0-9a-fA-F]*\).*/\1/p" "$WAYBAR_CSS"; }

cat > "$OUT" << EOF
[colors-dark]
background=$(get base00)
foreground=$(get base05)
regular0=$(get base00)
regular1=$(get base08)
regular2=$(get base0B)
regular3=$(get base0A)
regular4=$(get base0D)
regular5=$(get base0E)
regular6=$(get base0C)
regular7=$(get base05)
bright0=$(get base03)
bright1=$(get base08)
bright2=$(get base0B)
bright3=$(get base0A)
bright4=$(get base0D)
bright5=$(get base0E)
bright6=$(get base0C)
bright7=$(get base07)

[colors-light]
background=$(get base00)
foreground=$(get base05)
regular0=$(get base00)
regular1=$(get base08)
regular2=$(get base0B)
regular3=$(get base0A)
regular4=$(get base0D)
regular5=$(get base0E)
regular6=$(get base0C)
regular7=$(get base05)
bright0=$(get base03)
bright1=$(get base08)
bright2=$(get base0B)
bright3=$(get base0A)
bright4=$(get base0D)
bright5=$(get base0E)
bright6=$(get base0C)
bright7=$(get base07)
EOF
