import QtQuick
import Quickshell
import qs
import qs.components

Column {
    spacing: 10
    PillButton {
        width: parent.width
        text: "󰈋  Pick Screen Color"
        enabled: !Tasks.color.running
        onClicked: {
            ShellState.close();
            Tasks.color.start(["pick-color"]);
        }
    }
    TaskStatus {
        width: parent.width
        task: Tasks.color
    }
    Row {
        width: parent.width
        height: 44
        BodyText {
            width: parent.width - 44
            height: 44
            verticalAlignment: Text.AlignVCenter
            text: "Color History"
        }
        PillButton {
            width: 44
            text: "󰃢"
            Accessible.name: "Clear History"
            onClicked: History.clear("colors")
        }
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: History.entries.colors || []
            delegate: PillButton {
                required property var modelData
                width: 132
                height: 62
                text: modelData.color
                background: Rectangle {
                    radius: 18
                    color: Style.bg1
                    Rectangle {
                        x: 8
                        y: 8
                        width: 12
                        height: parent.height - 16
                        radius: 6
                        color: modelData.color
                    }
                }
                onClicked: Quickshell.execDetached(["wl-copy", "--", modelData.color])
            }
        }
    }
}
