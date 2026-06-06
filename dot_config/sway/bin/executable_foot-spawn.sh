#!/usr/bin/env bash
set -euo pipefail

command -v foot >/dev/null || exit 1

cwd=$(cat "${XDG_RUNTIME_DIR}/foot-last-cwd" 2>/dev/null)
if [[ -n "$cwd" && -d "$cwd" ]]; then
    exec foot --working-directory="$cwd"
fi

exec foot
