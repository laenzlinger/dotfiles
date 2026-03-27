#!/usr/bin/env bash
set -euo pipefail

command -v networkmanager_dmenu >/dev/null
command -v netbird >/dev/null

# Check VPN status
nb_mgmt=$(netbird status 2>/dev/null | grep "^Management:" | awk '{print $2}' || true)
if [[ "$nb_mgmt" == "Connected" ]]; then
    vpn_entry="󰒄 VPN Disconnect"
else
    vpn_entry="󰒃 VPN Connect"
fi

# Get WiFi networks from nmcli
wifi_list=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | sort -t: -k2 -rn | awk -F: '
    !seen[$1]++ && $1 != "" {
        sig = $2 + 0
        if (sig >= 75) icon = "󰤥"
        else if (sig >= 50) icon = "󰤢"
        else if (sig >= 25) icon = "󰤟"
        else icon = "󰤯"
        sec = ($3 != "") ? $3 : "Open"
        printf "%s  %s  %s\n", $1, sec, icon
    }')

# Show combined menu
choice=$(printf '%s\n%s\n' "$vpn_entry" "$wifi_list" | rofi -dmenu -i -p "Network")

case "$choice" in
    *"VPN Disconnect"*) netbird down ;;
    *"VPN Connect"*) netbird up ;;
    "") ;;
    *) ssid="${choice%%  *}"
       nmcli -a connection up "$ssid" 2>/dev/null || nmcli -a dev wifi connect "$ssid" ;;
esac
