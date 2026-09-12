import QtQuick
import qs
import qs.components

Row {
    spacing: 16
    Column {
        width: (parent.width - 16) / 2
        spacing: 7
        BodyText {
            text: "Tools"
            font.pixelSize: 20
        }
        Repeater {
            model: [["disks", "01  Disk space"], ["apps", "02  App manager"], ["search", "03  File search"], ["speed", "04  Speed test"], ["emoji", "05  Emoji"], ["color", "06  Color picker"], ["media", "07  Media tools"], ["download", "08  Downloader"], ["ip", "09  IP locator"], ["periodic", "10  Periodic table"]]
            delegate: PillButton {
                required property var modelData
                width: parent.width
                text: modelData[1]
                selected: ShellState.leftPanel === modelData[0]
                onClicked: ShellState.side(modelData[0], "left")
            }
        }
    }
    Column {
        width: (parent.width - 16) / 2
        spacing: 7
        BodyText {
            text: "Settings"
            font.pixelSize: 20
        }
        Repeater {
            model: [["config", "01  Hyprland config"], ["update", "02  System update"], ["clean", "03  System clean"], ["account", "04  User / password"], ["startup", "05  Startup apps"], ["defaults", "06  Default apps"], ["network", "07  Network settings"], ["appearance", "08  Wallpaper / theme"], ["power", "09  Session / power"], ["diagnostics", "10  Diagnostics"]]
            delegate: PillButton {
                required property var modelData
                width: parent.width
                text: modelData[1]
                selected: ShellState.rightPanel === modelData[0]
                onClicked: ShellState.side(modelData[0], "right")
            }
        }
    }
}
