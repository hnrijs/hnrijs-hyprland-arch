#!/usr/bin/env bash
set -euo pipefail
printf 'Full Arch system update\n'
sudo pacman -Syu
printf '\nUpdate completed.\n'
