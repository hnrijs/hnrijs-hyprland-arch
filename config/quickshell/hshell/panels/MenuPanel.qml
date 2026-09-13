import QtQuick
import qs
import qs.components

Flow {
    property string kind: "menu"
    spacing: 12
    Repeater {
        model: kind === "menu" ? [["settings", "󰒓", "Settings"], ["tools", "󰛣", "Tools"]] : [["apps", "󰏗", "Applications"], ["speed", "󰓅", "Speed Test"], ["media", "󰎁", "Media"], ["exif", "󰈙", "EXIF"], ["download", "󰇚", "Downloader"], ["ip", "󰩟", "IP Locator"], ["periodic", "󰂓", "Periodic Table"], ["calculator", "󰃬", "Calculator"], ["color", "󰈋", "Color Picker"], ["emoji", "󰞅", "Emoji"]]
        delegate: PillButton {
            required property var modelData
            width: (parent.width - (kind === "menu" ? 12 : 36)) / (kind === "menu" ? 2 : 4)
            height: kind === "menu" ? 100 : 82
            text: modelData[1]
            font.family: Style.iconFontFamily
            font.pixelSize: 30
            detail: ""
            Accessible.name: modelData[2]
            onClicked: {
                if (["settings", "tools"].includes(modelData[0]))
                    ShellState.setPanel(modelData[0]);
                else
                    ShellState.side(modelData[0], "left");
            }
        }
    }
}
