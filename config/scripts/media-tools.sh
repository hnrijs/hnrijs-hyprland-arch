#!/usr/bin/env bash
set -euo pipefail
file=$(fd --type f --print0 -e mp4 -e mkv -e webm -e mov -e mp3 -e flac -e wav -e png -e jpg -e jpeg -e webp . "$HOME" | fzf --read0 --print0 | tr -d '\0') || exit 0
[[ -n $file ]] || exit 0
printf '1) Inspect metadata  2) Remove audio  3) Rotate clockwise  4) Mirror horizontally\n5) Extract MP3  6) Resize video  7) Trim  8) Convert image to PNG\n'
read -r -p 'Choice: ' choice
base=${file%.*}
suffix=$(date +%Y%m%d-%H%M%S)
case $choice in
    1) exiftool "$file" | less ;;
    2) ffmpeg -n -i "$file" -c copy -an "${base}-silent-${suffix}.${file##*.}" ;;
    3) ffmpeg -n -i "$file" -vf transpose=1 "${base}-rotated-${suffix}.${file##*.}" ;;
    4) ffmpeg -n -i "$file" -vf hflip "${base}-mirrored-${suffix}.${file##*.}" ;;
    5) ffmpeg -n -i "$file" -vn "${base}-audio-${suffix}.mp3" ;;
    6)
        read -r -p 'Width (height is calculated automatically): ' width
        [[ $width =~ ^[1-9][0-9]{0,4}$ ]] || exit 2
        ffmpeg -n -i "$file" -vf "scale=$width:-2" "${base}-scaled-${suffix}.mp4"
        ;;
    7)
        read -r -p 'Start (HH:MM:SS): ' start
        read -r -p 'Duration (HH:MM:SS): ' duration
        [[ $start =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ && $duration =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || exit 2
        ffmpeg -n -ss "$start" -i "$file" -t "$duration" -c copy "${base}-trimmed-${suffix}.${file##*.}"
        ;;
    8) magick "$file" "${base}-converted-${suffix}.png" ;;
    *) exit 0 ;;
esac
