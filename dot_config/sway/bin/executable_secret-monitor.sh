#!/usr/bin/env bash
set -euo pipefail

command -v dbus-monitor >/dev/null || exit 1
command -v busctl >/dev/null || exit 1
command -v notify-send >/dev/null || exit 1

find_caller_parent() {
    local pid=$1
    # Skip the direct caller (secret-tool etc), then skip shells, return first real process
    local ppid
    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') || return
    pid=$ppid
    while [ "$pid" -gt 1 ]; do
        local comm
        comm=$(ps -o comm= -p "$pid" 2>/dev/null) || break
        case "$comm" in
            sh|bash|zsh|dash) ;;
            *)
                local args
                args=$(ps -o args= -p "$pid" 2>/dev/null) || break
                echo "${comm}|${args}"
                return
                ;;
        esac
        ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') || break
        pid=$ppid
    done
}

last_sender=""

dbus-monitor --session "interface='org.freedesktop.Secret.Service',member='SearchItems'" \
                       "interface='org.freedesktop.Secret.Service',member='GetSecrets'" 2>/dev/null |
while read -r line; do
    if [[ "$line" =~ ^method\ call.*sender=(:1\.[0-9]+).*member=(SearchItems|GetSecrets) ]]; then
        sender="${BASH_REMATCH[1]}"
        [ "$sender" = "$last_sender" ] && continue
        last_sender="$sender"

        pid=$(busctl --user status "$sender" 2>/dev/null | grep "^PID=" | cut -d= -f2) || continue
        [ -z "$pid" ] && continue

        parent=$(find_caller_parent "$pid") || continue
        [ -z "$parent" ] && continue

        name="${parent%%|*}"
        args="${parent#*|}"
        notify-send -a "KeePassXC" "󰌾 ${name}" "${args}" -t 10000
    fi
done
