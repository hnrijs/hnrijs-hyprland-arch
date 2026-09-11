#!/bin/bash

while true; do
    if [ -f /tmp/dnd ]; then
        dnd_state="󰂛  Do Not Disturb: ON"
    else
        dnd_state="󰂚  Do Not Disturb: OFF"
    fi

    clear_btn="󰎟  Clear All Notifications"
    close_btn="󰅖  Close Menu"

    history=$(dunstctl history 2>/dev/null | jq -r '.data[0][] | "   \(.appname.data): \(.summary.data)"' 2>/dev/null)

    if [ -z "$history" ]; then
        options="$dnd_state\n$clear_btn\n$close_btn\n   (Empty)"
    else
        options="$dnd_state\n$clear_btn\n$close_btn\n$history"
    fi

    chosen="$(echo -e "$options" | rofi -normal-window -dmenu -format i -p " Notifications")"
    
    case "$chosen" in
        0)
            if [ -f /tmp/dnd ]; then
                rm -f /tmp/dnd
                dunstctl set-paused false
            else
                touch /tmp/dnd
                dunstctl set-paused true
            fi
            sleep 0.1
            ;;
        1)
            dunstctl close-all
            dunstctl history-clear 2>/dev/null
            sleep 0.1
            ;;
        2|*)
            break
            ;;
    esac
done
