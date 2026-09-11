#!/bin/bash

if ! command -v xprintidle >/dev/null 2>&1 || ! command -v xdotool >/dev/null 2>&1; then
    notify-send -u critical "Missing packages" "Please install:\nsudo pacman -S xprintidle xdotool xorg-xprop"
    exit 1
fi

DAEMON_NAME="dwm-idle-daemon"

start_idle_daemon() {
    exec -a "$DAEMON_NAME" bash -c '
        while true; do
            idle=$(xprintidle 2>/dev/null || echo 0)
            
            if pgrep -x "slock" > /dev/null; then
                is_locked=1
            else
                is_locked=0
            fi

            if [ "$is_locked" -eq 0 ] && [ "$idle" -ge 45000 ]; then
                blocked=0
                
                if command -v pactl >/dev/null && pactl list sink-inputs 2>/dev/null | grep -qi "state: running"; then
                    blocked=1
                elif grep -q "RUNNING" /proc/asound/card*/pcm*/sub*/status 2>/dev/null; then
                    blocked=1
                fi
                
                if [ "$blocked" -eq 0 ]; then
                    active_win=$(xdotool getactivewindow 2>/dev/null)
                    if [ -n "$active_win" ] && xprop -id "$active_win" _NET_WM_STATE 2>/dev/null | grep -q "_NET_WM_STATE_FULLSCREEN"; then
                        blocked=1
                    fi
                fi
                
                if [ "$blocked" -eq 1 ]; then
                    xdotool key Shift_L
                    sleep 5
                    continue
                fi
            fi

            if [ "$is_locked" -eq 0 ] && [ "$idle" -ge 60000 ]; then
                slock &
                sleep 2
                continue
            fi

            if [ "$idle" -ge 300000 ]; then
                systemctl suspend
                sleep 10
            fi

            sleep 5
        done
    '
}

if pgrep -f "$DAEMON_NAME" > /dev/null; then
    pkill -f "$DAEMON_NAME"
    xset -dpms
    xset s off
    touch /tmp/caffeine
    notify-send -u normal "Caffeine Mode" "Enabled: System Will Stay Awake."
else
    xset -dpms
    xset s off
    rm -f /tmp/caffeine
    
    start_idle_daemon &
    
    notify-send -u normal "Idle Mode" "Enabled: Lock (1m) -> Sleep (5m)."
fi
