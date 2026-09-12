import QtQuick
import QtQuick.Controls
import qs

Slider {
    id: root
    property string icon: ""
    property string caption: ""
    property string displayValue: Math.round(value * 100) + "%"
    implicitHeight: 44
    from: 0
    to: 1
    hoverEnabled: true
    wheelEnabled: true
    focusPolicy: Qt.TabFocus
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding
        width: root.availableWidth
        height: root.availableHeight
        radius: height / 2
        color: Style.bg1
        Rectangle {
            x: 4
            y: 4
            width: Math.max(0, (parent.width - 8) * root.visualPosition)
            height: parent.height - 8
            radius: height / 2
            color: Style.primary
        }
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.visualPosition > 0.12 ? Style.bg0 : Style.foreground
            font.family: Style.fontFamily
            font.pixelSize: 18
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.displayValue
            color: root.visualPosition > 0.91 ? Style.bg0 : Style.foreground
            font.family: Style.fontFamily
            font.pixelSize: 14
        }
        border.width: root.visualFocus ? 2 : 0
        border.color: Style.primary
    }
    handle: Item {}
    ToolTip.visible: hovered
    ToolTip.text: caption + " · " + displayValue
    ToolTip.delay: 200
}
