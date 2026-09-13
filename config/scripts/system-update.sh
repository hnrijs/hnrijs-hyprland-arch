#!/usr/bin/env bash
set -euo pipefail
printf 'Full system update\n'
if command -v paru >/dev/null; then paru -Syu
elif command -v yay >/dev/null; then yay -Syu
else sudo pacman -Syu
fi
