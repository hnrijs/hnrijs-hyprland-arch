#!/usr/bin/env bash
set -euo pipefail
scripts=${XDG_CONFIG_HOME:-$HOME/.config}/scripts
action=${1:-}
if [[ $action == terminal ]]; then
    shift
    status=0
    bash "$0" "$@" || status=$?
    printf '\nFinished with exit code %s. Press Enter to close.\n' "$status"
    read -r _ || true
    exit "$status"
fi
case $action in
    update) bash "$scripts/system_update.sh" ;;
    clean) bash "$scripts/system_clean.sh" ;;
    disk) ncdu "$HOME" ;;
    processes) btop ;;
    info) fastfetch ;;
    monitors) hyprctl monitors ;;
    keyboard) hyprctl devices ;;
    keyboard-us) hyprctl eval 'hl.config({input = {kb_layout = "us"}})' ;;
    keyboard-lv) hyprctl eval 'hl.config({input = {kb_layout = "lv"}})' ;;
    network|dns) nmtui ;;
    bluetooth) bluetoothctl ;;
    firewall) sudo ufw status verbose ;;
    firewall-enable) sudo ufw enable ;;
    firewall-disable) sudo ufw disable ;;
    install-app)
        mapfile -t packages < <(pacman -Slq | fzf --multi --preview 'pacman -Si {1}')
        ((${#packages[@]} == 0)) || sudo pacman -S --needed -- "${packages[@]}"
        ;;
    remove-app)
        mapfile -t packages < <(pacman -Qq | fzf --multi --preview 'pacman -Qi {1}')
        ((${#packages[@]} == 0)) || sudo pacman -Rns -- "${packages[@]}"
        ;;
    find-file)
        file=$(fd --type f --print0 . "$HOME" | fzf --read0 --print0 | tr -d '\0') || exit 0
        [[ -z $file ]] || xdg-open "$file"
        ;;
    find-text)
        read -r -p 'Search text: ' term
        [[ -z $term ]] || rg --fixed-strings -- "$term" "$HOME" | less -R
        ;;
    weather)
        read -r -p 'Location: ' location
        encoded=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$location")
        curl --fail --show-error --max-time 20 "https://wttr.in/$encoded?0T"
        ;;
    speed) speedtest-cli ;;
    downloader) bash "$scripts/downloader.sh" ;;
    media) bash "$scripts/media-tools.sh" ;;
    periodic)
        selected=$(python3 "$scripts/periodic.py" | fzf --prompt='Element: ') || exit 0
        [[ -z $selected ]] || printf '%s' "$selected" | awk '{printf "%s", $2}' | wl-copy
        ;;
    edit-hypr) nvim "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua" ;;
    edit-local) nvim "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/local.lua" ;;
    *) printf 'Unknown tool: %s\n' "$action" >&2; exit 2 ;;
esac
