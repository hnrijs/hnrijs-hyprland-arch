#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
state_home=${XDG_STATE_HOME:-$HOME/.local/state}
config_only=false
use_lightdm=true
for arg in "$@"; do
  case $arg in
  --config-only) config_only=true ;;
  --no-lightdm) use_lightdm=false ;;
  --help)
    printf 'Run as your normal user: bash install.sh [--config-only] [--no-lightdm]\n'
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\n' "$arg" >&2
    exit 2
    ;;
  esac
done
[[ $EUID -ne 0 ]] || {
  echo 'Run as your normal desktop user, without sudo.' >&2
  exit 1
}
[[ $HOME == /* && $HOME != / && $config_home == /* && $state_home == /* ]] || {
  echo 'Use absolute HOME/XDG paths.' >&2
  exit 1
}
[[ -f $SCRIPT_DIR/config/quickshell/hshell/shell.qml ]] || {
  echo 'Extract or clone the complete repository.' >&2
  exit 1
}
if ! $config_only; then
  command -v pacman >/dev/null || {
    echo 'This installer targets Arch Linux and compatible distributions.' >&2
    exit 1
  }
  command -v sudo >/dev/null || {
    echo 'Install sudo and grant this user access first.' >&2
    exit 1
  }
  sudo -v
  required=(
    adwaita-icon-theme alacritty aria2 awww bash bluez bluez-utils brightnessctl
    cliphist curl dbus desktop-file-utils fd ffmpeg fontconfig fzf gawk git
    gnome-keyring grim gtk3 gvfs gvfs-mtp hypridle hyprland hyprlock hyprpicker
    hyprsunset imagemagick imv jq less libnotify libpulse librewolf monolith mpv
    networkmanager neovim noto-fonts noto-fonts-emoji pacman-contrib perl-image-exiftool
    cava pipewire pipewire-alsa pipewire-pulse playerctl polkit power-profiles-daemon python
    qt6-declarative qt6-imageformats qt6-multimedia-ffmpeg qt6-wayland quickshell
    ripgrep slurp speedtest-cli thunar thunar-volman ttf-jetbrains-mono-nerd tumbler
    udisks2 upower util-linux wget wireplumber wl-clipboard xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland xdg-user-dirs xdg-utils xdg-terminal-exec yt-dlp
  )
  $use_lightdm && required+=(lightdm lightdm-gtk-greeter xorg-server)
  sudo pacman -Syu --needed --noconfirm "${required[@]}"
  [[ $(vercmp "$(pacman -Q quickshell | awk '{print $2}')" 0.3.1) -ge 0 ]] || {
    echo 'Quickshell 0.3.1+ with Polkit/Networking support is required.' >&2
    exit 1
  }
  [[ $(vercmp "$(pacman -Q hyprland | awk '{print $2}')" 0.55.0) -ge 0 ]] || {
    echo 'Hyprland 0.55+ with Lua configuration is required.' >&2
    exit 1
  }
fi
command -v python3 >/dev/null || {
  echo 'Python 3 is required.' >&2
  exit 1
}
python3 "$SCRIPT_DIR/installer/install-config.py" --source "$SCRIPT_DIR" --home "$HOME" --config "$config_home" --state "$state_home"
# Embed the actual per-user state location for hyprlock (also supports XDG_STATE_HOME).
python3 - "$config_home/hypr/hyprlock.conf" "$state_home" <<'PY'
from pathlib import Path
import sys
path=Path(sys.argv[1]);path.write_text(path.read_text().replace('$HOME/.local/state',sys.argv[2]))
PY
if ! $config_only; then
  python3 "$config_home/scripts/default-apps.py"
  gtk_theme=Adwaita-dark
  if [[ -d $SCRIPT_DIR/theme ]]; then
    while IFS= read -r -d '' directory; do
      sudo mkdir -p /usr/share/themes
      sudo cp -a -- "$directory" /usr/share/themes/
      gtk_theme=${directory##*/}
    done < <(find "$SCRIPT_DIR/theme" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  fi
  # Existing GTK settings in config/ are preserved/copied; shell theme changes never edit GTK.
  sudo systemctl enable --now NetworkManager.service bluetooth.service power-profiles-daemon.service
  if $use_lightdm; then
    sudo install -Dm755 "$SCRIPT_DIR/installer/polkit/set-login-wallpaper" /usr/lib/hshell/set-login-wallpaper
    sudo install -Dm644 "$SCRIPT_DIR/installer/polkit/org.hshell.wallpaper.policy" /usr/share/polkit-1/actions/org.hshell.wallpaper.policy
    sudo mkdir -p /usr/share/pixmaps
    initial=$(mktemp --suffix=.png)
    trap 'rm -f -- "$initial"' EXIT
    if [[ -f $SCRIPT_DIR/main.png ]]; then
      magick "$SCRIPT_DIR/main.png[0]" -strip "PNG:$initial"
    else
      magick -size 16x16 xc:'#1e1e2e' "PNG:$initial"
    fi
    sudo install -m644 "$initial" /usr/share/pixmaps/main-wallpaper.png
    rm -f -- "$initial"
    trap - EXIT
    stamp=$(date +%s)
    greeter=/etc/lightdm/lightdm-gtk-greeter.conf
    if sudo test -f "$greeter"; then sudo cp -a "$greeter" "$greeter.hshell-backup-$stamp"; fi
    printf '[greeter]\nbackground = /usr/share/pixmaps/main-wallpaper.png\ntheme-name = %s\nicon-theme-name = Adwaita\nfont-name = JetBrainsMono Nerd Font 12\n' "$gtk_theme" | sudo tee "$greeter" >/dev/null
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    if sudo test -f /etc/lightdm/lightdm.conf.d/50-hshell.conf; then sudo cp -a /etc/lightdm/lightdm.conf.d/50-hshell.conf "/etc/lightdm/lightdm.conf.d/50-hshell.conf.backup-$stamp"; fi
    printf '[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=hyprland\n' | sudo tee /etc/lightdm/lightdm.conf.d/50-hshell.conf >/dev/null
    # User selected LightDM installation: make it the login manager and graphical boot target.
    sudo systemctl enable --force lightdm.service
    sudo systemctl set-default graphical.target
  fi
fi
printf '\nhshell installed. Backups are in %s/hshell/backups.\n' "$state_home"
printf 'Shell only: qs -c hshell\n'
if ! $config_only && $use_lightdm; then
  if [[ -z ${WAYLAND_DISPLAY:-} && -z ${DISPLAY:-} ]]; then
    printf 'Starting LightDM. Select Hyprland on the login screen.\n'
    sudo systemctl start lightdm.service
  else
    printf 'LightDM is enabled for the next boot. Your current graphical session was not interrupted.\n'
  fi
fi
