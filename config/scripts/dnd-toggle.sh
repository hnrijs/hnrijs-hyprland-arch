#!/bin/bash

if [ -f /tmp/dnd ]; then
    rm -f /tmp/dnd
    dunstctl set-paused false
    dunstify -u normal "Notifications" "Do Not Disturb: OFF"
else
    touch /tmp/dnd
    dunstctl set-paused true
fi
