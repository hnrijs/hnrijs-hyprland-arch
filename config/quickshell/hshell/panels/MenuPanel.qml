import QtQuick
import qs
import qs.components

Column {
    property string kind: "menu"
    spacing: 8
    Repeater {
        model: kind === "menu" ? [["settings", "󰒓", "Settings"], ["tools", "󰏗", "Tools"]] : kind === "tools" ? [["apps", "󰏗", "App manager"], ["speed", "󰓅", "Speed test"], ["media", "󰎁", "Media tools"], ["download", "󰇚", "Downloader"], ["ip", "󰩟", "IP locator"], ["periodic", "󰂓", "Periodic table"]] : [["config", "󰖳", "Hyprland & startup"], ["defaults", "󰈙", "Default apps"], ["account", "󰀄", "User / password"], ["update", "󰚰", "System update"], ["clean", "󰃢", "System clean"], ["appearance", "󰸉", "Wallpaper & theme"]]
        delegate: PillButton {
            required property var modelData
            width: parent.width
            text: modelData[1] + "   " + modelData[2]
            onClicked: {
                if (["settings", "tools"].includes(modelData[0]))
                    ShellState.setPanel(modelData[0]);
                else if (modelData[0] === "appearance")
                    ShellState.setPanel("wallpaper");
                else
                    ShellState.side(modelData[0], "left");
            }
        }
    }
}
