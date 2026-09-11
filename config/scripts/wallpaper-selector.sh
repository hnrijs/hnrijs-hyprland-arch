#!/bin/bash

wall_dir="${HOME}/Pictures/Wallpapers"
cache_dir="${HOME}/.cache/thumbnails/wal_selector"
lightdm_wall="/usr/share/pixmaps/main-wallpaper.png"

mkdir -p "${cache_dir}" "${wall_dir}"
shopt -s nullglob

for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}; do
    if [ -f "$imagen" ]; then
        filename=$(basename "$imagen")
        if [ ! -f "${cache_dir}/${filename}" ] ; then
            magick "$imagen" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_dir}/${filename}"
        fi
    fi
done

rofi_override="
window { 
    width: 880px; 
    border-radius: 0px; 
}
listview { 
    columns: 4; 
    lines: 3; 
    spacing: 15px; 
    fixed-height: true; 
    fixed-columns: true; 
    scrollbar: true; 
    flow: horizontal; 
}
scrollbar { 
    handle-width: 5px; 
    handle-color: #FFFFFF; 
    background-color: #151515; 
    border: 0px; 
}
element { 
    orientation: vertical; 
    padding: 15px; 
    border-radius: 0px; 
}
element-icon { 
    size: 150px; 
    horizontal-align: 0.5; 
}
element-text { 
    horizontal-align: 0.5; 
    padding: 10px 0 0 0; 
}
"

wall_selection=$(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort -V | while read -r A ; do
    echo -en "$A\0icon\x1f${cache_dir}/$A\n"
done | rofi -normal-window -dmenu -theme-str "${rofi_override}" -p "󰸉 Wallpapers")

if [[ -n "$wall_selection" ]]; then
    selected_wp="${wall_dir}/${wall_selection}"
    
    xwallpaper --zoom "$selected_wp"
    
    if [ -w "$lightdm_wall" ]; then
        cat "$selected_wp" > "$lightdm_wall"
    else
        pkexec cp "$selected_wp" "$lightdm_wall"
    fi

    if [ -f "$HOME/.xprofile" ]; then
        sed -i "s|xwallpaper --zoom .*|xwallpaper --zoom \"$selected_wp\" \&|g" "$HOME/.xprofile"
    fi

    if [ -f "$HOME/.xinitrc" ] && grep -q "xwallpaper" "$HOME/.xinitrc"; then
        sed -i "s|xwallpaper --zoom .*|xwallpaper --zoom \"$selected_wp\" \&|g" "$HOME/.xinitrc"
    fi
    
    dunstify -a "sysmenu_osd" -u normal -h string:x-dunst-stack-tag:wallpaper "󰸉 Wallpaper Changed" "Applied: $wall_selection"
fi

exit 0
