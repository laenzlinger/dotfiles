#!/usr/bin/env bash
set -euo pipefail

# Spawn a new WezTerm window inheriting the last-used terminal's cwd.
# Zsh writes $PWD to $XDG_RUNTIME_DIR/wezterm-last-cwd on every prompt via precmd.

command -v wezterm >/dev/null || exit 1

cwd=$(cat "${XDG_RUNTIME_DIR}/wezterm-last-cwd" 2>/dev/null)
if [[ -n "$cwd" && -d "$cwd" ]]; then
    exec wezterm start --cwd "$cwd"
fi

exec wezterm start
