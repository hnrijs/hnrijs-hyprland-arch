#!/bin/bash

sleep 0.1

rofi_override="
window { 
    width: 880px; 
    border-radius: 0px; 
}
listview { 
    columns: 6; 
    lines: 10; 
    spacing: 15px; 
    fixed-height: true; 
    fixed-columns: true; 
    scrollbar: true; 
}
scrollbar { 
    handle-width: 5px; 
    handle-color: #FFFFFF; 
    background-color: #151515; 
    border: 0px; 
}
element { 
    padding: 10px; 
    border-radius: 0px; 
}
"

rofimoji --action copy --selector-args "-normal-window -theme-str '${rofi_override}'"
