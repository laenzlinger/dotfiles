#!/usr/bin/env bash

# Network info
WIFI=$(nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | cut -d: -f2,3)
if [ -n "$WIFI" ]; then
    SSID=$(echo "$WIFI" | cut -d: -f1)
    SIGNAL=$(echo "$WIFI" | cut -d: -f2)
    IP=$(ip -4 addr show wlp0s20f3 2>/dev/null | grep inet | awk '{print $2}')
    GW=$(ip route | grep default | awk '{print $3}')
    NET_TEXT="  $SSID ($SIGNAL%)"
    NET_TIP="$SSID ($SIGNAL%)\n$IP\nGateway: $GW"
else
    ETH=$(ip -4 addr show | grep -E "inet.*scope global" | head -1)
    if [ -n "$ETH" ]; then
        IFACE=$(echo "$ETH" | awk '{print $NF}')
        IP=$(echo "$ETH" | awk '{print $2}')
        GW=$(ip route | grep default | awk '{print $3}')
        NET_TEXT="󰈀 $IFACE"
        NET_TIP="$IFACE\n$IP\nGateway: $GW"
    else
        NET_TEXT="No connection"
        NET_TIP="Disconnected"
    fi
fi

# VPN info
NB_STATUS=$(netbird status 2>/dev/null)
NB_MGMT=$(echo "$NB_STATUS" | grep "^Management:" | cut -d' ' -f2)
NB_IP=$(echo "$NB_STATUS" | grep "^NetBird IP:" | cut -d' ' -f3)

if [ "$NB_MGMT" = "Connected" ]; then
    NET_TEXT="$NET_TEXT 󰒄"
    NET_TIP="$NET_TIP\nVPN: $NB_IP"
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$NET_TEXT" "$NET_TIP"
