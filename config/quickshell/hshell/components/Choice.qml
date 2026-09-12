import QtQuick
import QtQuick.Controls
import qs

ComboBox {
    id: root
    implicitHeight: 44
    font.family: Style.fontFamily
    font.pixelSize: Style.fontSize
    palette.text: Style.foreground
    palette.buttonText: Style.foreground
    palette.window: Style.bg0
    palette.base: Style.bg0
    palette.button: Style.bg1
    palette.highlight: Style.primary
    palette.highlightedText: Style.bg0
    background: Rectangle {
        radius: height / 2
        color: Style.bg1
        border.color: Style.primary
        border.width: root.visualFocus ? 2 : 0
    }
    contentItem: Text {
        text: root.displayText
        color: Style.foreground
        font: root.font
        verticalAlignment: Text.AlignVCenter
        leftPadding: 14
        rightPadding: 32
        elide: Text.ElideRight
    }
    indicator: Text {
        x: root.width - width - 14
        anchors.verticalCenter: parent.verticalCenter
        text: "⌄"
        color: Style.primary
        font.pixelSize: 18
    }
    delegate: ItemDelegate {
        id: option
        required property var modelData
        required property int index
        width: root.width
        highlighted: root.highlightedIndex === index
        contentItem: Text {
            text: modelData
            color: Style.foreground
            font: root.font
            elide: Text.ElideRight
        }
        background: Rectangle {
            color: option.highlighted ? Style.bg3 : Style.bg0
            radius: 14
        }
    }
    popup: Popup {
        popupType: Popup.Window
        y: root.height + 4
        width: root.width
        padding: 6
        implicitHeight: Math.min(contentItem.implicitHeight + 12, 280)
        background: Rectangle {
            radius: 18
            color: Style.bg0
            border.color: Style.bg3
            border.width: 1
        }
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
