import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: window

    required property var notificationModel

    implicitWidth: 390
    implicitHeight: screen ? screen.height - 28 : popupStack.implicitHeight
    color: "transparent"
    visible: !ShellState.dnd && popupStack.implicitHeight > 0
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "hshell-notifications"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 14
        right: 14
    }

    Column {
        id: popupStack

        width: parent.width
        spacing: 8

        Repeater {
            model: window.notificationModel

            delegate: NotificationCard {
                required property var modelData

                width: popupStack.width
                notification: modelData
            }
        }
    }

    mask: Region {
        item: popupStack
    }
}
