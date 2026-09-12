import QtQuick
import QtQuick.Controls
import Quickshell
import qs
import qs.components

Column {
    id: root
    property var selected: Elements.entries[0]
    spacing: 10
    Field {
        id: search
        width: parent.width
        placeholderText: "Element name, symbol or number"
    }
    BodyText {
        width: parent.width
        text: root.selected.number + " · " + root.selected.symbol + " · " + root.selected.name
        font.pixelSize: 18
    }
    PillButton {
        width: parent.width
        text: "Copy symbol"
        onClicked: Quickshell.execDetached(["wl-copy", "--", root.selected.symbol])
    }
    ScrollView {
        width: parent.width
        height: 420
        contentWidth: 810
        Item {
            width: 810
            height: 410
            Repeater {
                model: Elements.entries
                delegate: Rectangle {
                    required property var modelData
                    x: (modelData.col - 1) * 45
                    y: (modelData.row - 1) * 40
                    width: 42
                    height: 37
                    radius: 10
                    color: root.selected.number === modelData.number ? Style.primary : Style.bg1
                    opacity: !search.text || String(modelData.name + modelData.symbol + modelData.number).toLowerCase().includes(search.text.toLowerCase()) ? 1 : 0.25
                    BodyText {
                        anchors.centerIn: parent
                        text: modelData.symbol
                        color: root.selected.number === modelData.number ? Style.bg0 : Style.foreground
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.selected = modelData
                    }
                }
            }
        }
    }
    BodyText {
        width: parent.width
        text: "Scroll horizontally for groups 1–18. Lanthanides and actinides are shown below."
        color: Style.muted
    }
}
