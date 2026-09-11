#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
state_home=${XDG_STATE_HOME:-$HOME/.local/state}
config_only=false
personal=false
install_apps=true
use_lightdm=true
for arg in "$@"; do
    case $arg in
        --config-only) config_only=true ;;
        --personal) personal=true ;;
        --minimal) install_apps=false ;;
        --no-lightdm) use_lightdm=false ;;
        --help)
            printf 'Usage: bash install.sh [--personal] [--minimal] [--no-lightdm] [--config-only]\n\n'
            printf 'Run as your normal user on Arch Linux.\n'
            printf '  --personal     Enable your supplied four-monitor/NVIDIA/LV overrides.\n'
            printf '  --minimal      Skip optional desktop applications.\n'
            printf '  --no-lightdm   Keep your existing login manager.\n'
            printf '  --config-only  Copy config and wallpapers; skip packages and system changes.\n'
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done
[[ $EUID -ne 0 ]] || { echo 'Run this as your normal desktop user, not sudo/root.' >&2; exit 1; }
[[ $HOME == /* && $HOME != / && $config_home == /* && $state_home == /* ]] || {
    echo 'HOME and XDG paths must be absolute.' >&2; exit 1;
}
[[ -f $SCRIPT_DIR/config/quickshell/hshell/shell.qml ]] || {
    echo 'Missing config/quickshell/hshell/shell.qml. Extract the complete package.' >&2; exit 1;
}

if ! $config_only; then
    command -v pacman >/dev/null || { echo 'This installer targets Arch Linux.' >&2; exit 1; }
    command -v sudo >/dev/null || { echo 'Install sudo and grant this user access first.' >&2; exit 1; }
    sudo -v
    required=(
        adwaita-icon-theme alacritty awww bash bluez bluez-utils brightnessctl btop cliphist curl
        dbus fd ffmpeg firefox fontconfig fzf gawk gdk-pixbuf2 git glib2
        gnome-keyring gsettings-desktop-schemas gtk3 gvfs gvfs-mtp hypridle
        hyprland hyprlock hyprpicker hyprsunset imagemagick imv jq less libnotify
        libpulse networkmanager neovim noto-fonts noto-fonts-emoji nwg-look
        pacman-contrib pavucontrol pipewire pipewire-alsa pipewire-jack pipewire-pulse
        playerctl polkit polkit-gnome power-profiles-daemon python qt6-declarative
        qt6-imageformats qt6-multimedia-ffmpeg qt6-virtualkeyboard qt6-wayland
        quickshell ripgrep thunar thunar-volman ttf-jetbrains-mono-nerd tumbler
        udisks2 ufw unzip upower util-linux wget wireplumber wl-clipboard
        xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-user-dirs xdg-utils
        yt-dlp zip grim slurp ncdu aria2 perl-image-exiftool
    )
    if $use_lightdm; then required+=(lightdm lightdm-gtk-greeter xorg-server); fi
    # Refresh and upgrade together: no partial upgrade from pacman -Sy.
    sudo pacman -Syu --needed --noconfirm "${required[@]}"
    [[ $(vercmp "$(pacman -Q quickshell | awk '{print $2}')" 0.3.0) -ge 0 ]] || {
        echo 'hshell requires Quickshell 0.3 or newer, including Networking support.' >&2; exit 1;
    }
    [[ $(vercmp "$(pacman -Q hyprland | awk '{print $2}')" 0.55.0) -ge 0 ]] || {
        echo 'This config requires a Hyprland release with Lua configuration (0.55+).' >&2; exit 1;
    }
    if $install_apps; then
        optional=(
            android-udev audacious base-devel fastfetch ffmpegthumbnailer gimp
            jdk-openjdk krita lazygit libreoffice-fresh librewolf monolith nano
            nodejs npm noto-fonts-cjk obs-studio openssh proton-vpn-gtk-app
            python-gobject python-requests qt5-wayland signal-desktop smartmontools
            speedtest-cli ttf-dejavu ttf-font-awesome ttf-nerd-fonts-symbols
        )
        declare -A available=()
        while IFS= read -r package; do available["$package"]=1; done < <(pacman -Slq)
        installable=()
        skipped=()
        for package in "${optional[@]}"; do
            if [[ -n ${available[$package]:-} ]]; then installable+=("$package");
            else skipped+=("$package"); fi
        done
        ((${#installable[@]} == 0)) || sudo pacman -S --needed --noconfirm "${installable[@]}"
        if ((${#skipped[@]})); then
            mkdir -p "$state_home/hshell"
            printf '%s\n' "${skipped[@]}" > "$state_home/hshell/optional-packages-not-in-repos.txt"
            printf 'Not in enabled repositories (install separately if wanted): %s\n' "${skipped[*]}"
        fi
    fi
fi

command -v python3 >/dev/null || { echo 'Python 3 is required to install the config.' >&2; exit 1; }
options=()
$personal && options+=(--personal)
python3 "$SCRIPT_DIR/installer/install-config.py" --source "$SCRIPT_DIR" \
    --home "$HOME" --config "$config_home" --state "$state_home" "${options[@]}"

if ! $config_only; then
    # Keep your repository GTK theme. It does not control hshell colors.
    gtk_theme=Adwaita-dark
    if [[ -d $SCRIPT_DIR/theme ]]; then
        while IFS= read -r -d '' directory; do
            name=${directory##*/}
            sudo mkdir -p -- /usr/share/themes
            sudo cp -a -- "$directory" /usr/share/themes/
            gtk_theme=$name
        done < <(find "$SCRIPT_DIR/theme" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    fi
    export HSHELL_GTK_THEME=$gtk_theme
    export HSHELL_CONFIG_HOME=$config_home
    export HSHELL_STATE_HOME=$state_home
    python3 - <<'PY'
import configparser, os, shutil
from datetime import datetime
from pathlib import Path
config = Path(os.environ['HSHELL_CONFIG_HOME'])
state = Path(os.environ['HSHELL_STATE_HOME'])
file = config / 'gtk-3.0/settings.ini'
settings = configparser.ConfigParser(interpolation=None)
settings.optionxform = str
if file.exists():
    backup = state / 'hshell/backups' / datetime.now().strftime('%Y%m%d-%H%M%S-%f') / 'gtk-3.0-settings.ini'
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(file, backup)
    settings.read(file)
if not settings.has_section('Settings'): settings.add_section('Settings')
settings['Settings'].update({'gtk-theme-name': os.environ['HSHELL_GTK_THEME'],
    'gtk-icon-theme-name': 'Adwaita', 'gtk-font-name': 'JetBrainsMono Nerd Font 11'})
file.parent.mkdir(parents=True, exist_ok=True)
with file.open('w') as output: settings.write(output)
PY
    if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" || true
        gsettings set org.gnome.desktop.interface icon-theme Adwaita || true
        xdg-mime default thunar.desktop inode/directory || true
    fi
    sudo systemctl enable --now NetworkManager.service bluetooth.service power-profiles-daemon.service
    if $use_lightdm; then
        background_line='background = #000000'
        if [[ -f $SCRIPT_DIR/main.png ]]; then
            sudo install -Dm644 "$SCRIPT_DIR/main.png" /usr/share/pixmaps/main-wallpaper.png
            background_line='background = /usr/share/pixmaps/main-wallpaper.png'
        fi
        # Shared greeter background stays root-owned; per-user wallpaper choices remain per-user.
        greeter=/etc/lightdm/lightdm-gtk-greeter.conf
        if sudo test -f "$greeter"; then sudo cp -a "$greeter" "$greeter.hshell-backup-$(date +%s)"; fi
        printf '[greeter]\n%s\ntheme-name = %s\nicon-theme-name = Adwaita\nfont-name = JetBrainsMono Nerd Font 11\n' \
            "$background_line" "$gtk_theme" | sudo tee "$greeter" >/dev/null
        sudo mkdir -p /etc/lightdm/lightdm.conf.d
        if sudo test -f /etc/lightdm/lightdm.conf.d/50-hshell.conf; then
            sudo cp -a /etc/lightdm/lightdm.conf.d/50-hshell.conf "/etc/lightdm/lightdm.conf.d/50-hshell.conf.backup-$(date +%s)"
        fi
        printf '[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=hyprland\n' \
            | sudo tee /etc/lightdm/lightdm.conf.d/50-hshell.conf >/dev/null
        current=$(readlink -f /etc/systemd/system/display-manager.service || true)
        if [[ -z $current || $current == */lightdm.service ]]; then
            sudo systemctl enable lightdm.service
        else
            printf 'Existing login manager retained: %s\n' "$current"
        fi
    fi
fi
printf '\nhshell installed. Log out and select Hyprland to start the full session.\n'
printf 'Manual shell start: qs -c hshell\n'
printf 'Local hardware overrides: %s/hypr/local.lua\n' "$config_home"
printf 'No automatic reboot.\n'
