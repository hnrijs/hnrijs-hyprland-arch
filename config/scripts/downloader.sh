#!/usr/bin/env bash
set -euo pipefail
printf '1) MP3  2) MP4  3) File/image  4) Magnet  5) Web page HTML  6) Git clone\n'
read -r -p 'Choice: ' choice
[[ $choice =~ ^[1-6]$ ]] || exit 0
read -r -p 'URL: ' url
[[ -n $url ]] || exit 0
if [[ $choice == 4 ]]; then
    [[ $url == magnet:* ]] || { echo 'Expected a magnet URL.' >&2; exit 2; }
else
    [[ $url == https://* || $url == http://* ]] || { echo 'Expected an HTTP(S) URL.' >&2; exit 2; }
fi
read -r -p "Save folder (default: $HOME/Downloads): " destination
destination=${destination:-$HOME/Downloads}
case $destination in '~') destination=$HOME ;; '~/'*) destination=$HOME/${destination:2} ;; esac
mkdir -p -- "$destination"
cd -- "$destination"
case $choice in
    1|2)
        read -r -p 'Download a playlist? [y/N] ' answer
        playlist=--no-playlist
        [[ $answer != [yY] ]] || playlist=--yes-playlist
        if [[ $choice == 1 ]]; then
            yt-dlp -x --audio-format mp3 "$playlist" -- "$url"
        else
            yt-dlp -S ext:mp4:m4a --merge-output-format mp4 "$playlist" -- "$url"
        fi
        ;;
    3) wget --https-only --content-disposition -- "$url" ;;
    4) aria2c --seed-time=0 -- "$url" ;;
    5) monolith "$url" -o "page-$(date +%Y%m%d-%H%M%S).html" ;;
    6) git clone -- "$url" ;;
esac
notify-send 'Download finished' "$destination"
