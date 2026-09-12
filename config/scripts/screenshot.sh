#!/usr/bin/env bash
set -euo pipefail
folder=$HOME/Pictures/Screenshots
mkdir -p "$folder"
file=$(mktemp "$folder/screenshot-$(date +%Y%m%d-%H%M%S)-XXXXXX.png")
trap 'rm -f -- "$file"' ERR
case ${1:-full} in
    full) grim "$file" ;;
    region)
        if ! geometry=$(slurp); then rm -f -- "$file"; exit 0; fi
        grim -g "$geometry" "$file"
        ;;
    *) rm -f -- "$file"; exit 2 ;;
esac
wl-copy --type image/png < "$file"
notify-send 'Screenshot saved' "$file"
