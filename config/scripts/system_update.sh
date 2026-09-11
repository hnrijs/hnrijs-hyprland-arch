#!/bin/bash

echo "Starting Full System Update"

echo "Updating Pacman packages..."
sudo pacman -Syu --noconfirm

echo "Update Complete!"
