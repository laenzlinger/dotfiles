#!/usr/bin/env bash
find "$HOME" -type f -not -path '*/.*' 2>/dev/null | rofi -dmenu -i -p "Search" -async-pre-read 0 | xargs -r xdg-open
