#!/usr/bin/env bash
set -euo pipefail

command -v netbird >/dev/null

action="${1:-up}"
nid=(-h string:x-canonical-private-synchronous:vpn -h boolean:transient:true)

if [[ "$action" == "up" ]]; then
    notify-send "${nid[@]}" "󰒃   VPN" "Connecting..."
    if netbird up 2>/dev/null; then
        notify-send "${nid[@]}" "󰒄   VPN" "Connected"
    else
        notify-send "${nid[@]}" "󰒃   VPN" "Connection failed"
    fi
else
    notify-send "${nid[@]}" "󰒄   VPN" "Disconnecting..."
    if netbird down 2>/dev/null; then
        notify-send "${nid[@]}" "󰒃   VPN" "Disconnected"
    else
        notify-send "${nid[@]}" "󰒄   VPN" "Disconnect failed"
    fi
fi

pkill -RTMIN+1 waybar || true
