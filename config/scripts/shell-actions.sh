#!/usr/bin/env bash
set -euo pipefail

action=${1:-}
night_light_state_file=${XDG_STATE_HOME:-"$HOME/.local/state"}/hshell/night-light-temperature

clipboard_list() {
  local cache_dir line id preview extension image_path
  cache_dir=${XDG_RUNTIME_DIR:-/run/user/$UID}/hshell-clipboard
  mkdir -p "$cache_dir"

  while IFS= read -r line; do
    id=${line%%$'\t'*}
    preview=${line#*$'\t'}
    if [[ $id =~ ^[0-9]+$ && $preview =~ \ (png|jpg|jpeg|webp|gif|bmp)\  ]]; then
      extension=${BASH_REMATCH[1]}
      image_path=$cache_dir/$id.$extension
      if [[ ! -s $image_path ]]; then
        cliphist decode "$id" > "$image_path"
      fi
      printf '%s\t%s\tfile://%s\n' "$id" "$preview" "$image_path"
    else
      printf '%s\n' "$line"
    fi
  done < <(cliphist list | head -n 50)
}

brightness_device() {
  local path device maximum best_device= best_maximum=-1

  for path in /sys/class/backlight/*; do
    [[ -r $path/max_brightness ]] || continue
    read -r maximum < "$path/max_brightness"
    [[ $maximum =~ ^[0-9]+$ ]] || continue
    if (( maximum > best_maximum )); then
      device=${path##*/}
      best_device=$device
      best_maximum=$maximum
    fi
  done

  [[ -n $best_device ]] || return 1
  printf '%s\n' "$best_device"
}

case "$action" in
  brightness-get)
    device=$(brightness_device) || { echo -1; exit 0; }
    brightnessctl -d "$device" -m | awk -F, '{ gsub(/%/, "", $4); print $4; exit }'
    ;;
  brightness-set)
    percentage=${2:?brightness percentage required}
    [[ $percentage =~ ^[0-9]+$ ]] && (( percentage >= 0 && percentage <= 100 ))
    device=$(brightness_device)
    brightnessctl -d "$device" set "$percentage%" >/dev/null
    ;;
  night-light-status)
    command -v hyprsunset >/dev/null || { echo unavailable; exit; }
    pgrep -u "$UID" -x hyprsunset >/dev/null && echo on || echo off
    ;;
  night-light-temperature-get)
    temperature=4500
    if [[ -r $night_light_state_file ]]; then
      read -r saved_temperature < "$night_light_state_file"
      if [[ $saved_temperature =~ ^[0-9]+$ ]] && (( saved_temperature >= 2500 && saved_temperature <= 6000 )); then
        temperature=$saved_temperature
      fi
    fi
    printf '%s\n' "$temperature"
    ;;
  night-light-toggle)
    command -v hyprsunset >/dev/null || exit 1
    temperature=${2:-4500}
    [[ $temperature =~ ^[0-9]+$ ]] && (( temperature >= 2500 && temperature <= 6000 ))
    mkdir -p -- "${night_light_state_file%/*}"
    printf '%s\n' "$temperature" > "$night_light_state_file"
    if pgrep -u "$UID" -x hyprsunset >/dev/null; then
      pkill -u "$UID" -x hyprsunset
    else
      hyprsunset -t "$temperature" >/dev/null 2>&1 &
    fi
    ;;
  night-light-set)
    command -v hyprsunset >/dev/null || exit 1
    temperature=${2:?night light temperature required}
    [[ $temperature =~ ^[0-9]+$ ]] && (( temperature >= 2500 && temperature <= 6000 ))
    mkdir -p -- "${night_light_state_file%/*}"
    printf '%s\n' "$temperature" > "$night_light_state_file"
    if pgrep -u "$UID" -x hyprsunset >/dev/null; then
      hyprctl hyprsunset temperature "$temperature" >/dev/null
    fi
    ;;
  power-profile-status)
    command -v powerprofilesctl >/dev/null || { echo unavailable; exit; }
    if profile=$(powerprofilesctl get 2>/dev/null); then
      echo "$profile"
    else
      echo unavailable
    fi
    ;;
  power-profile-cycle)
    command -v powerprofilesctl >/dev/null || exit 1
    current=$(powerprofilesctl get 2>/dev/null) || exit 1
    profiles=()
    while IFS= read -r line; do
      if [[ $line =~ ^[[:space:]*]*(power-saver|balanced|performance): ]]; then
        profiles+=("${BASH_REMATCH[1]}")
      fi
    done < <(powerprofilesctl list)
    ((${#profiles[@]} > 0)) || exit 1
    next=${profiles[0]}
    for index in "${!profiles[@]}"; do
      if [[ ${profiles[$index]} == "$current" ]]; then
        next=${profiles[$(((index + 1) % ${#profiles[@]}))]}
        break
      fi
    done
    powerprofilesctl set "$next"
    ;;
  clipboard-list)
    clipboard_list
    ;;
  clipboard-decode)
    [[ ${2:-} =~ ^[0-9]+$ ]]
    cliphist decode "$2"
    ;;
  clipboard-paste)
    [[ ${2:-} =~ ^[0-9]+$ ]]
    target=$(hyprctl activewindow -j | jq -r '.address // empty')
    [[ $target =~ ^0x[0-9a-fA-F]+$ ]]
    cliphist decode "$2" | wl-copy
    sleep 0.08
    hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = \"CTRL\", key = \"V\", window = \"address:$target\" }))" >/dev/null
    ;;
  power)
    case "${2:-}" in
      lock)
        if command -v hyprlock >/dev/null; then
          hyprlock --config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprlock.conf"
        else
          loginctl lock-session
        fi
        ;;
      suspend) systemctl suspend ;;
      logout) hyprctl dispatch 'hl.dsp.exit()' ;;
      reboot) systemctl reboot ;;
      shutdown) systemctl poweroff ;;
      *) exit 2 ;;
    esac
    ;;
  *)
    printf 'unknown action: %s\n' "$action" >&2
    exit 2
    ;;
esac
