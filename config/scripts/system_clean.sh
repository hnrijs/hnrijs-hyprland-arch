#!/bin/bash

echo "Starting System Cleanup"

if [ -n "$(pacman -Qtdq)" ]; then
  echo "Removing orphaned packages..."
  sudo pacman -Rns $(pacman -Qtdq) --noconfirm
else
  echo "No orphaned packages found."
fi

echo "Cleaning pacman cache..."
sudo pacman -Sc --noconfirm

echo "Cleaning thumbnail cache..."
rm -rf "$HOME/.cache/thumbnails/"*

echo "Cleanup Complete!"
