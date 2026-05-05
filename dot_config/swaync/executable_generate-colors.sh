#!/bin/bash
# Generate swaync colors.css from waybar colors
cp "${1:-$HOME/.config/waybar/colors.css}" ~/.config/swaync/colors.css
