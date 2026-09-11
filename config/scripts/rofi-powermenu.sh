#!/usr/bin/env bash

hibernate=''
shutdown='󰐥'
reboot=''
lock='󰌾'
suspend='󰤄'
logout='󰍃'

rofi_cmd() {
    rofi -normal-window -dmenu \
         -theme "$HOME/.config/rofi/rofi-powermenu-config.rasi"
}

run_rofi() {
    echo -e "$lock\n$logout\n$shutdown\n$reboot\n$suspend\n$hibernate" | rofi_cmd
}

run_cmd() {
    if [[ $1 == '--shutdown' ]]; then
        systemctl poweroff || loginctl poweroff
    elif [[ $1 == '--reboot' ]]; then
        systemctl reboot || loginctl reboot
    elif [[ $1 == '--hibernate' ]]; then
        systemctl hibernate
    elif [[ $1 == '--suspend' ]]; then
        amixer set Master mute
        systemctl suspend
    elif [[ $1 == '--logout' ]]; then
        pkill dwm  
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $hibernate)
        run_cmd --hibernate
        ;;
    $lock)
        slock
        ;;
    $suspend)
        slock & sleep 0.5 
        run_cmd --suspend
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
