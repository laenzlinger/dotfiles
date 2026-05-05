#!/usr/bin/env bash
set -euo pipefail
# Generate rofi colors.rasi from a waybar-format CSS file (atomic write)
input="${1:-$HOME/.config/waybar/colors.css}"
tmp=$(mktemp)
{ echo '* {'; sed -n 's/@define-color \(base[0-9A-F]*\) \(#[0-9a-fA-F]*\);/\1: \2;/p' "$input"; echo '}'; } > "$tmp"
mv "$tmp" ~/.config/rofi/colors.rasi
