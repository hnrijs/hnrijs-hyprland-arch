#!/bin/bash

PLATFORMS="  YouTube\n  Reddit\n  GitHub\n󰚩  Gemini\n  Maps\n󰗊  Translate\n󰖐  Windy"

INPUT=$(echo -e "$PLATFORMS" | rofi -normal-window -dmenu -p "Web" -i)

[ -z "$INPUT" ] && exit 1

CLEAN_INPUT=$(echo "$INPUT" | sed 's/^[[:space:]]*[^[:space:]]*[[:space:]]*//')
TARGET=$(echo "$INPUT" | awk '{print $2}')
[ -z "$TARGET" ] && TARGET=$(echo "$INPUT" | awk '{print $1}')

case "$TARGET" in
"YouTube") librewolf "https://youtube.com" & ;;
"Reddit") librewolf "https://reddit.com" & ;;
"GitHub") librewolf "https://github.com" & ;;
"Gemini") librewolf "https://gemini.google.com/" & ;;
"Maps") librewolf "https://google.com/maps" & ;;
"Translate") librewolf "https://translate.google.com" & ;;
"Windy") librewolf "https://windy.com" & ;;
esac
