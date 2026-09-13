import QtQuick
import Quickshell.Io
import qs

Item {
    id: root
    property bool active: false
    readonly property var levels: Cava.levels
    Row {
        anchors.fill: parent
        spacing: 3
        Repeater {
            model: 5
            delegate: Rectangle {
                required property int index
                width: Math.max(2, (root.width - 12) / 5)
                height: Math.max(2, root.height * root.levels[index * 2] / 100)
                y: root.height - height
                radius: width / 2
                color: Style.primary
            }
        }
    }
}
