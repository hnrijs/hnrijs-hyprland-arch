import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: window
    required property var notificationModel
    implicitWidth: Math.min(460, screen ? screen.width - 24 : 460)
    implicitHeight: screen ? screen.height : 800
    color: "transparent"
    visible: Preferences.notifications && !ShellState.dnd && notificationModel.length > 0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "hshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors.top: true
    Column {
        id: popupStack
        y: 64
        width: parent.width
        spacing: 8
        Repeater {
            model: window.notificationModel
            delegate: NotificationCard {
                required property var modelData
                width: popupStack.width
                height: implicitHeight
                notification: modelData
            }
        }
    }
    mask: Region {
        item: popupStack
    }
}
