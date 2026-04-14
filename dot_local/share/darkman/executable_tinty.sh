#!/usr/bin/env bash
set -euo pipefail

PIDFILE="/tmp/tinty-switch.pid"

# Kill previous tinty apply session (entire process group)
if [[ -f "$PIDFILE" ]]; then
  prev=$(cat "$PIDFILE" 2>/dev/null || true)
  if [[ -n "$prev" ]] && kill -0 "$prev" 2>/dev/null; then
    kill -- -"$prev" 2>/dev/null || true
  fi
fi

case "$1" in
dark) THEME=base16-darktooth ;;
light) THEME=base16-gruvbox-light-medium ;;
esac

SWAYSOCK=$(find /run/user/"$(id -u)" -name 'sway-ipc.*.sock' -print -quit 2>/dev/null)
if [[ -z "$SWAYSOCK" ]]; then
  echo "tinty.sh: No sway socket found, skipping" >&2
  exit 0
fi
export SWAYSOCK

# Run in new session so kill -PGID can stop the whole tree
setsid /usr/bin/tinty apply "$THEME" &
echo $! > "$PIDFILE"
wait $! || true
rm -f "$PIDFILE"
