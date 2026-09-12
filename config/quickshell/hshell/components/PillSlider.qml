import QtQuick
import QtQuick.Controls
import qs

Slider {
    id: root
    property string icon: ""
    property string caption: ""
    property string displayValue: Math.round(value * 100) + "%"
    property bool compact: false
    from: 0
    to: 1
    implicitHeight: compact ? 28 : 48
    padding: 0
    hoverEnabled: true
    wheelEnabled: true
    focusPolicy: Qt.TabFocus
    background: Rectangle {
        width: root.width
        height: root.height
        radius: height / 2
        color: Style.bg1
        Rectangle {
            width: Math.max(height, parent.width * root.position)
            height: parent.height
            radius: height / 2
            color: root.enabled ? Style.activeFill : Style.bg3
        }
        Text {
            x: 16
            height: parent.height
            width: 24
            text: root.icon
            font.family: Style.fontFamily
            font.pixelSize: root.compact ? 14 : 21
            verticalAlignment: Text.AlignVCenter
            color: root.enabled ? Style.activeText : Style.muted
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            height: parent.height
            text: root.displayValue
            font.family: Style.fontFamily
            font.pixelSize: root.compact ? 12 : 13
            verticalAlignment: Text.AlignVCenter
            color: root.position > 0.88 && root.enabled ? Style.activeText : Style.foreground
        }
    }
    handle: Item {}
    Accessible.name: caption
}
