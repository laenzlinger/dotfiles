#!/usr/bin/env bash
set -euo pipefail
command -v sed >/dev/null || exit 1

WAYBAR_CSS="${1:-$HOME/.config/waybar/colors.css}"
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

# Update running foot terminals via OSC sequences
osc() { printf '\e]%s;#%s\e\\' "$1" "$2"; }
for pts in /dev/pts/[0-9]*; do
  [[ -w "$pts" ]] || continue
  {
    osc 10 "$(get base05)"  # foreground
    osc 11 "$(get base00)"  # background
    osc 4\;0 "$(get base00)"
    osc 4\;1 "$(get base08)"
    osc 4\;2 "$(get base0B)"
    osc 4\;3 "$(get base0A)"
    osc 4\;4 "$(get base0D)"
    osc 4\;5 "$(get base0E)"
    osc 4\;6 "$(get base0C)"
    osc 4\;7 "$(get base05)"
    osc 4\;8 "$(get base03)"
    osc 4\;9 "$(get base08)"
    osc 4\;10 "$(get base0B)"
    osc 4\;11 "$(get base0A)"
    osc 4\;12 "$(get base0D)"
    osc 4\;13 "$(get base0E)"
    osc 4\;14 "$(get base0C)"
    osc 4\;15 "$(get base07)"
  } > "$pts" 2>/dev/null || true
done
