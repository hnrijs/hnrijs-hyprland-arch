import QtQuick
import qs
import qs.components

Flow {
    spacing: 12
    Repeater {
        model: [["interface", "󰏘", "Interface", "Colors and Controls"], ["system", "󰒓", "System", "Updates and Cleanup"], ["network", "󰈀", "Network", "DNS and Firewall"], ["wallpaper", "󰸉", "Wallpaper", "Browse Images"]]
        delegate: ControlTile {
            required property var modelData
            width: (parent.width - 12) / 2
            symbol: modelData[1]
            text: modelData[2]
            detail: modelData[3]
            onClicked: modelData[0] === "wallpaper" ? ShellState.setPanel("wallpaper") : ShellState.side(modelData[0], "left")
        }
    }
}
