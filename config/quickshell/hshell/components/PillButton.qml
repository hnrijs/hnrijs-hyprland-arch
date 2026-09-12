import QtQuick
import QtQuick.Controls
import qs

Button {
    id: root
    property string detail: ""
    property bool selected: false
    implicitHeight: detail ? 66 : 42
    implicitWidth: 140
    font.family: Style.fontFamily
    font.pixelSize: Style.fontSize
    hoverEnabled: true
    focusPolicy: Qt.TabFocus
    background: Rectangle {
        radius: height / 2
        color: root.selected ? Style.primary : (root.hovered ? Style.bg3 : Style.bg1)
        border.width: root.visualFocus ? 2 : 0
        border.color: Style.primary
    }
    contentItem: Column {
        spacing: 3
        Text {
            width: parent.width
            text: root.text
            font: root.font
            color: root.selected ? Style.bg0 : Style.foreground
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }
        Text {
            width: parent.width
            visible: !!root.detail
            text: root.detail
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSize - 2
            color: root.selected ? Style.bg0 : Style.muted
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }
    }
    ToolTip.visible: hovered && detail.length > 18
    ToolTip.text: detail
    ToolTip.delay: 500
}
