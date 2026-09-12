import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: window

    required property var notificationModel

    implicitWidth: 460
    implicitHeight: Math.min(screen ? screen.height - 80 : 800, popupStack.implicitHeight)
    color: "transparent"
    visible: !ShellState.dnd && popupStack.implicitHeight > 0
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "hshell-notifications"

    anchors {
        top: true
    }

    margins {
        top: 64
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
