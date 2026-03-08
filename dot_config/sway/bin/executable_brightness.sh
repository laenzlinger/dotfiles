#!/usr/bin/env bash
set -euo pipefail
command -v brightnessctl >/dev/null || exit 1
brightnessctl -m | cut -d, -f4 | tr -d %
