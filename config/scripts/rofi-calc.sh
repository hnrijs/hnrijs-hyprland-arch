#!/bin/bash

sleep 0.1

while true; do
  calc_opts="  Open Calculator\n  Formatting Guide\n  Clear History\n  Back"
  calc_chosen="$(echo -e "$calc_opts" | rofi -normal-window -dmenu -p "Calculator")"
  case "$calc_chosen" in
  *"Open Calculator"*)
    rofi -normal-window -show calc -modi calc -no-show-match -no-sort -calc-command "echo -n '{result}' | xclip -selection clipboard"
    ;;
  *"Formatting Guide"*)
    guide="15% of 200 = 30\n200 + 15% = 230\n100 USD to EUR = 92.5 EUR\n5 cm to in = 1.96 in\n1.5 hours to min = 90 min\n1.5 kW to W = 1500 W\n1/2 + 1/4 = 0.75\nsqrt(144) = 12\npi * 5^2 = 78.53"
    echo -e "$guide" | rofi -normal-window -dmenu -p "Examples (Esc to close)"
    ;;
  *"Clear History"*)
    rm -f "$HOME/.local/share/rofi/rofi_calc_history"
    dunstify "Calculator" "History cleared!"
    ;;
  "" | *"Back"*)
    break
    ;;
  esac
done
