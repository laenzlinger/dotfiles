#!/usr/bin/env bash
# Generate rofi colors.rasi from waybar colors.css
sed -n 's/@define-color \(base[0-9A-F]*\) \(#[0-9a-fA-F]*\);/\1: \2;/p' \
    ~/.config/waybar/colors.css > ~/.config/rofi/colors.rasi
sed -i '1i * {' ~/.config/rofi/colors.rasi
echo '}' >> ~/.config/rofi/colors.rasi
