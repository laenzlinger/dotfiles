#!/usr/bin/env bash
set -euo pipefail

command -v wezterm >/dev/null || exit 1
command -v yazi >/dev/null || exit 1

cwd=$(cat "${XDG_RUNTIME_DIR}/wezterm-last-cwd" 2>/dev/null || true)
[[ -n "$cwd" && -d "$cwd" ]] || cwd="$HOME"

exec wezterm start --class yazi --cwd "$cwd" -- yazi
