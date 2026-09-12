import QtQuick
import Quickshell.Io
import qs

Item {
    id: root
    property bool active: false
    property var levels: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    Process {
        command: ["cava", "-p", ShellState.scripts + "cava.conf"]
        running: root.active
        stdout: SplitParser {
            onRead: line => {
                const values = line.split(";").filter(v => v !== "").map(v => Math.max(0, Math.min(100, Number(v) || 0)));
                if (values.length === 10)
                    root.levels = values;
            }
        }
    }
    Row {
        anchors.fill: parent
        spacing: 3
        Repeater {
            model: 10
            delegate: Rectangle {
                required property int index
                width: (root.width - 27) / 10
                height: Math.max(2, root.height * root.levels[index] / 100)
                y: (root.height - height) / 2
                radius: width / 2
                color: Style.primary
            }
        }
    }
}
