#!/usr/bin/env bash
set -euo pipefail
pgrep -u "$UID" -x hyprlock >/dev/null && exit 0
exec hyprlock --config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprlock.conf"
