#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v git &>/dev/null; then
  sudo pacman -Sy --noconfirm git
fi

mkdir -p "$HOME/Documents" "$HOME/Music" "$HOME/Downloads" "$HOME/Pictures/Wallpapers" "$HOME/Videos" "$HOME/.config"

sudo pacman -S --needed --noconfirm \
  base-devel wget dolphin imv btop playerctl alacritty zip unzip polkit-kde-agent ark \
  wl-clipboard slurp grim ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-nerd-fonts-symbols \
  gtk3 pavucontrol nwg-look mpv brightnessctl nano android-udev \
  power-profiles-daemon python-gobject xdg-desktop-portal-hyprland hyprlock hypridle hyprpicker \
  lightdm lightdm-gtk-greeter dunst aria2 jdk-openjdk \
  curl jq xdg-utils libnotify librewolf imagemagick audacious kdegraphics-thumbnailers ffmpegthumbs \
  ttf-dejavu ttf-font-awesome noto-fonts monolith \
  noto-fonts-cjk udisks2 kio-extras dolphin-plugins redshift \
  signal-desktop obs-studio proton-vpn-gtk-app \
  less neovim ripgrep fd lazygit fastfetch yt-dlp \
  fzf ncdu python-requests exiftool speedtest-cli krita gimp nodejs npm

if [ -d "$SCRIPT_DIR/theme" ]; then
  sudo mkdir -p /usr/share/themes
  sudo cp -r "$SCRIPT_DIR/theme/"* /usr/share/themes/
fi

if [ -d "$SCRIPT_DIR/config" ]; then
  cp -r "$SCRIPT_DIR/config/"* "$HOME/.config/"
fi

if [ -f "$SCRIPT_DIR/main.png" ]; then
  cp "$SCRIPT_DIR/main.png" "$HOME/Pictures/Wallpapers/main.png"
  sudo cp "$SCRIPT_DIR/main.png" /usr/share/pixmaps/main-wallpaper.png
fi

if [ -d "$SCRIPT_DIR/Wallpapers" ]; then
  cp -r "$SCRIPT_DIR/Wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

sudo touch /usr/share/pixmaps/main-wallpaper.png
sudo chmod 666 /usr/share/pixmaps/main-wallpaper.png

sudo bash -c 'cat << EOF > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background = /usr/share/pixmaps/main-wallpaper.png
theme-name = catppuccin-mocha-blue-standard+default
icon-theme-name = Adwaita
font-name = JetBrainsMono Nerd Font 11
EOF'

mkdir -p "$HOME/.config/scripts"
if [ -d "$HOME/.config/scripts" ]; then
  chmod +x "$HOME/.config/scripts/"* 2>/dev/null || true
fi

find "$HOME/.config" -type f -exec sed -i "s|/home/[^/]*|$HOME|g" {} + 2>/dev/null || true

sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable lightdm

sleep 5
sudo reboot
