#!/usr/bin/env bash
set -euo pipefail

command -v foot >/dev/null || exit 1
command -v yazi >/dev/null || exit 1

cwd=$(cat "${XDG_RUNTIME_DIR}/foot-last-cwd" 2>/dev/null || true)
[[ -n "$cwd" && -d "$cwd" ]] || cwd="$HOME"

exec foot --app-id=yazi --working-directory="$cwd" yazi
