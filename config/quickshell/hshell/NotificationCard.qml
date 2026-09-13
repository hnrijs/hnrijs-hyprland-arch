import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs
import qs.components

Rectangle {
    id: root
    required property var notification
    implicitHeight: Math.max(78, content.implicitHeight + 30)
    radius: 25
    color: Style.bg0
    property int timeout: notification.expireTimeout === 0 || notification.urgency === NotificationUrgency.Critical ? 0 : notification.expireTimeout > 0 ? notification.expireTimeout : 5000
    Rectangle {
        x: 16
        y: 24
        width: 38
        height: 38
        radius: 19
        color: Style.bg1
        Text {
            anchors.centerIn: parent
            text: "󰂚"
            color: Style.foreground
            font.family: Style.iconFontFamily
            font.pixelSize: 20
        }
        IconImage {
            anchors.fill: parent
            anchors.margins: 7
            source: root.notification.image || (root.notification.appIcon ? Quickshell.iconPath(root.notification.appIcon) : "")
        }
    }
    Column {
        id: content
        x: 68
        y: 15
        width: parent.width - 86
        spacing: 5
        BodyText {
            width: parent.width
            text: root.notification.appName || "Notification"
            color: Style.muted
            font.pixelSize: 12
            textFormat: Text.PlainText
        }
        BodyText {
            width: parent.width
            text: root.notification.summary
            font.pixelSize: 16
            font.bold: true
            maximumLineCount: 2
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }
        BodyText {
            width: parent.width
            visible: text !== ""
            text: root.notification.body
            color: Style.muted
            maximumLineCount: 4
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }
        Flow {
            width: parent.width
            spacing: 6
            Repeater {
                model: root.notification.actions
                delegate: PillButton {
                    required property var modelData
                    width: 130
                    height: 32
                    text: modelData.text
                    onClicked: modelData.invoke()
                }
            }
        }
    }
    HoverHandler {
        id: hover
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.notification.dismiss()
    }
    Timer {
        interval: root.timeout
        running: root.timeout > 0 && !hover.hovered
        onTriggered: root.notification.expire()
    }
}
