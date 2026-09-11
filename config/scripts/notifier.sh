#!/bin/bash

pactl subscribe 2>/dev/null | grep --line-buffered "Event 'change' on sink" | (
    get_vol_state() {
        local vol_info mute_info
        vol_info=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null)
        mute_info=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null)
        
        if [[ $vol_info =~ ([0-9]+)% ]]; then
            current_vol="${BASH_REMATCH[1]}"
        else
            current_vol="0"
        fi
        
        if [[ $mute_info == *"yes"* ]]; then
            is_muted="yes"
        else
            is_muted="no"
        fi
    }

    get_vol_state
    prev_vol="$current_vol"
    prev_mute="$is_muted"

    while read -r _; do
        get_vol_state
        
        if [ "$current_vol" = "$prev_vol" ] && [ "$is_muted" = "$prev_mute" ]; then
            continue
        fi
        
        prev_vol="$current_vol"
        prev_mute="$is_muted"
        
        if [ "$is_muted" = "yes" ]; then
            dunstify -a "sysmenu_osd" -u normal -h string:x-dunst-stack-tag:osd "   Volume: Muted"
        else
            val=$current_vol
            [ "$val" -gt 100 ] && val=100
            dunstify -a "sysmenu_osd" -u normal -h string:x-dunst-stack-tag:osd -h int:value:"$val" " Volume: ${current_vol}%"
        fi
    done
) &

udevadm monitor --subsystem-match=backlight 2>/dev/null | grep --line-buffered "change" | while read -r _; do
    br_info=$(brightnessctl i)
    if [[ $br_info =~ \(([0-9]+)%\) ]]; then
        current_br="${BASH_REMATCH[1]}"
        dunstify -a "sysmenu_osd" -u normal -h string:x-dunst-stack-tag:osd -h int:value:"$current_br" "   Brightness: ${current_br}%"
    fi
done &

(
    declare -A usb_devices
    for syspath in /sys/bus/usb/devices/*; do
        if [ -e "$syspath/busnum" ]; then
            real_path=$(realpath "$syspath")
            devpath="${real_path#/sys}"
            model=$(udevadm info -q property -p "$devpath" 2>/dev/null | grep -E '^(ID_MODEL_FROM_DATABASE|ID_MODEL)=' | head -n 1 | cut -d= -f2-)
            if [ -n "$model" ]; then
                usb_devices["$devpath"]=$(echo "$model" | tr '_' ' ')
            fi
        fi
    done

    udevadm monitor --udev --property --subsystem-match=usb 2>/dev/null | while read -r line; do
        if [[ "$line" =~ ^UDEV ]]; then
            action=""
            is_device=""
            model=""
            devpath=""
        elif [[ "$line" == ACTION=* ]]; then 
            action="${line#ACTION=}"
        elif [[ "$line" == DEVPATH=* ]]; then
            devpath="${line#DEVPATH=}"
        elif [[ "$line" == DEVTYPE=usb_device ]]; then 
            is_device=1
        elif [[ "$line" == ID_MODEL=* && -z "$model" ]]; then 
            model="${line#ID_MODEL=}"
        elif [[ "$line" == ID_MODEL_FROM_DATABASE=* ]]; then 
            model="${line#ID_MODEL_FROM_DATABASE=}"
        elif [[ -z "$line" ]]; then
            if [[ "$is_device" == "1" && -n "$devpath" ]]; then
                if [[ "$action" == "add" && -n "$model" ]]; then
                    model=$(echo "$model" | tr '_' ' ')
                    usb_devices["$devpath"]="$model"
                    notify-send -u normal -t 4000 "  Device Connected" "$model"
                elif [[ "$action" == "remove" ]]; then
                    model="${usb_devices[$devpath]}"
                    if [[ -n "$model" ]]; then
                        notify-send -u normal -t 4000 "  Device Disconnected" "$model"
                        unset usb_devices["$devpath"]
                    fi
                fi
            fi
            action=""; is_device=""; model=""; devpath=""
        fi
    done
) &

nmcli monitor 2>/dev/null | while read -r line; do
    if [[ "$line" == *"connected to"* ]]; then
        network="${line#*connected to }"
        notify-send -u normal -t 4000 "   Network Connected" "$network"
    elif [[ "$line" == *"disconnected"* ]]; then
        iface="${line%%:*}"
        iface="${iface%% *}"
        notify-send -u normal -t 4000 "   Network Disconnected" "$iface"
    fi
done &

dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.bluez.Device1'" 2>/dev/null | while read -r line; do
    if [[ "$line" == *"path=/org/bluez/hci0/dev_"* ]]; then
        mac="${line##*dev_}"
        mac="${mac%%[\"\']*}"
        mac="${mac//_/:}"
    elif [[ "$line" == *'string "Connected"'* ]]; then
        read -r next_line
        if [[ "$next_line" == *'boolean true'* ]]; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u normal -t 4000 "   Bluetooth Connected" "$name"
        elif [[ "$next_line" == *'boolean false'* ]]; then
            name=$(bluetoothctl info "$mac" 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}')
            [ -z "$name" ] && name="Device ($mac)"
            notify-send -u normal -t 4000 "   Bluetooth Disconnected" "$name"
        fi
    fi
done &

(
    notified_15=false
    notified_5=false

    while true; do
        if [ -f /sys/class/power_supply/BAT0/capacity ] && [ -f /sys/class/power_supply/BAT0/status ]; then
            bat_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
            bat_status=$(cat /sys/class/power_supply/BAT0/status)

            if [ "$bat_status" = "Charging" ] || [ "$bat_status" = "Full" ]; then
                notified_15=false
                notified_5=false
            elif [ "$bat_status" = "Discharging" ]; then
                if [ "$bat_capacity" -le 5 ] && [ "$notified_5" = false ]; then
                    notify-send -u normal "󰂎 Battery Critical!" "Only $bat_capacity% remaining."
                    notified_5=true
                elif [ "$bat_capacity" -le 15 ] && [ "$notified_15" = false ]; then
                    notify-send -u normal "󰁻 Battery Low" "$bat_capacity% remaining."
                    notified_15=true
                fi
            fi
        fi
        sleep 60
    done
) &

wait
