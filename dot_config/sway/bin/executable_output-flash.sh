#!/usr/bin/env bash
set -uo pipefail
command -v swaymsg >/dev/null || exit 1
command -v jq >/dev/null || exit 1

swaymsg -t subscribe -m '["workspace"]' | jq --unbuffered -r '.current.output' | {
    last_output=""
    while read -r output; do
        if [ "$output" != "$last_output" ]; then
            last_output="$output"
            # shellcheck disable=SC2016
            swaymsg 'client.focused $base0A $base0A $base00 $base0A $base0A'
            swaymsg '[focused] border pixel 20'
            sleep 1
            swaymsg '[focused] border normal 2'
            # shellcheck disable=SC2016
            swaymsg 'client.focused $base05 $base03 $base06 $base03 $base05'
        fi
    done
}
