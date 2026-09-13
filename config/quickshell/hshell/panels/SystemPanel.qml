import QtQuick
import Quickshell
import qs
import qs.components

Flow {
    spacing: 12
    Repeater {
        model: [["update", "󰚰", "System Update"], ["clean", "󰃢", "System Clean"], ["edit-hypr", "󰒓", "Hyprland"], ["password", "󰌾", "Password"]]
        delegate: ControlTile {
            required property var modelData
            width: (parent.width - 12) / 2
            symbol: modelData[1]
            text: modelData[2]
            onClicked: Quickshell.execDetached(["alacritty", "-e", "bash", ShellState.scripts + "tools.sh", "terminal", modelData[0]])
        }
    }
}
