import QtQuick
import qs

Column {
    id: root
    required property string kind
    spacing: 8
    Row {
        width: parent.width
        height: 44
        BodyText {
            width: parent.width - 44
            height: 44
            verticalAlignment: Text.AlignVCenter
            text: "History"
        }
        PillButton {
            width: 44
            text: "󰃢"
            Accessible.name: "Clear History"
            onClicked: History.clear(root.kind)
        }
    }
    Repeater {
        model: History.entries[root.kind] || []
        delegate: Rectangle {
            required property var modelData
            width: parent.width
            height: label.implicitHeight + 24
            radius: 18
            color: Style.bg1
            BodyText {
                id: label
                x: 12
                y: 12
                width: parent.width - 24
                text: root.kind === "speed" ? Number(modelData.download || 0).toFixed(1) + " ↓ / " + Number(modelData.upload || 0).toFixed(1) + " ↑ Mbps · " + Math.round(modelData.ping || 0) + " ms\n" + modelData.time : [modelData.ip, modelData.city, modelData.country, modelData.time].filter(Boolean).join(" · ")
                font.pixelSize: 12
            }
        }
    }
}
