#!/usr/bin/env bash
set -euo pipefail

# Network info
WIFI=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2,3 || true)
if [ -n "$WIFI" ]; then
    SSID=$(echo "$WIFI" | cut -d: -f1)
    SIGNAL=$(echo "$WIFI" | cut -d: -f2)
    IFACE=$(nmcli -t -f device,type dev | grep ':wifi$' | cut -d: -f1 | head -1)
    IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep inet | awk '{print $2}')
    GW=$(ip route | grep default | awk '{print $3}' | head -1)
    if [ "$SIGNAL" -ge 75 ]; then ICON="󰤥"
    elif [ "$SIGNAL" -ge 50 ]; then ICON="󰤢"
    elif [ "$SIGNAL" -ge 25 ]; then ICON="󰤟"
    else ICON="󰤯"; fi
    NET_TEXT="$ICON  $SSID"
    NET_TIP="$SSID ($SIGNAL%)\n$IP\nGateway: $GW"
else
    ETH=$(ip -4 addr show | grep -E "inet.*scope global" | head -1 || true)
    if [ -n "$ETH" ]; then
        IFACE=$(echo "$ETH" | awk '{print $NF}')
        IP=$(echo "$ETH" | awk '{print $2}')
        GW=$(ip route | grep default | awk '{print $3}' | head -1)
        CONN=$(nmcli -t -f name,device con show --active 2>/dev/null | grep ":${IFACE}$" | cut -d: -f1)
        NET_TEXT="󰄜 ${CONN:-$IFACE}"
        NET_TIP="${CONN:-$IFACE}\n$IP\nGateway: $GW"
    else
        NET_TEXT="󰤭  Down"
        NET_TIP="Network disconnected"
    fi
fi

# VPN info
NB_STATUS=$(netbird status 2>/dev/null || true)
NB_MGMT=$(echo "$NB_STATUS" | grep "^Management:" | cut -d' ' -f2 || true)
NB_IP=$(echo "$NB_STATUS" | grep "^NetBird IP:" | cut -d' ' -f3 || true)

if [ "$NB_MGMT" = "Connected" ]; then
    NET_TEXT="$NET_TEXT 󰒄"
    NET_TIP="$NET_TIP\nVPN: $NB_IP"
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$NET_TEXT" "$NET_TIP"
