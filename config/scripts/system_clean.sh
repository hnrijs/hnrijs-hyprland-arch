#!/usr/bin/env bash
set -euo pipefail
printf 'Packages no longer required by another package:\n'
mapfile -t orphans < <(pacman -Qtdq || true)
if ((${#orphans[@]})); then
    printf '  %s\n' "${orphans[@]}"
    read -r -p 'Remove these packages and their unused dependencies? [y/N] ' answer
    if [[ $answer == [yY] ]]; then sudo pacman -Rns -- "${orphans[@]}"; fi
else
    printf 'None.\n'
fi
printf '\nPackage cache: keep the newest three versions of each package.\n'
read -r -p 'Prune older cached packages? [y/N] ' answer
if [[ $answer == [yY] ]]; then sudo paccache -rk3; fi
