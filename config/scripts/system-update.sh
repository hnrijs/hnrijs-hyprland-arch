#!/usr/bin/env bash
set -euo pipefail
if command -v yay >/dev/null; then yay -Syu
else sudo pacman -Syu
fi
