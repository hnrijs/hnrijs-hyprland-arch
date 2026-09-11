#!/usr/bin/env bash
set -euo pipefail
runtime=${XDG_RUNTIME_DIR:?Run this inside a Wayland session}
exec 9>"$runtime/hshell-session.lock"
flock -n 9 || exit 0
config=${XDG_CONFIG_HOME:-$HOME/.config}
scripts=$config/scripts
state=${XDG_STATE_HOME:-$HOME/.local/state}/hshell
mkdir -p "$state"
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE >/dev/null 2>&1 || true
children=()
start() { "$@" 9>&- >>"$state/session.log" 2>&1 & children+=("$!"); }
cleanup() { local pid; while IFS= read -r pid; do kill "$pid" 2>/dev/null || true; done < <(jobs -pr); }
trap cleanup EXIT
trap 'exit 0' TERM INT
pgrep -u "$UID" -x awww-daemon >/dev/null || start awww-daemon
start python3 "$scripts/wallpaper.py" restore-wallpaper
start wl-paste --type text --watch cliphist store
start wl-paste --type image --watch cliphist store
pgrep -u "$UID" -x hypridle >/dev/null || start hypridle -c "$config/hypr/hypridle.conf"
if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
    start /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
fi
start gnome-keyring-daemon --start --components=secrets
start qs -c hshell --no-duplicate
# End session-owned background processes when the compositor goes away.
while hyprctl version >/dev/null 2>&1; do sleep 5; done
