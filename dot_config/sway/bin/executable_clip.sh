#!/usr/bin/env bash
set -euo pipefail
if ! wl-paste --list-types 2>/dev/null | grep -q 'x-kde-passwordManagerHint'; then
    clipman --notify store --no-persist
fi
