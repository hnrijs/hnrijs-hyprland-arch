#!/usr/bin/env bash
set -euo pipefail
for browser in librewolf firefox chromium; do
    if command -v "$browser" >/dev/null; then exec "$browser" "$@"; fi
done
printf 'Install LibreWolf, Firefox or Chromium.\n' >&2
exit 127
