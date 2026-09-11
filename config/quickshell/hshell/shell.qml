import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

ShellRoot {
    id: root


    NotificationServer {
        id: notificationServer

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        onNotification: notification => {
            notification.tracked = true;
            ShellState.rememberNotification(notification);
        }
    }

    NotificationPopups {
        notificationModel: notificationServer.trackedNotifications
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    LowBatteryMonitor {}

    Variants {
        model: Quickshell.screens

        Island {
            required property var modelData

            screen: modelData
        }

    }

    IpcHandler {
        function toggle(panel: string) {
            ShellState.show(panel);
        }

        function close() {
            ShellState.close();
        }

        function next() {
            ShellState.cycle(1);
        }

        function previous() {
            ShellState.cycle(-1);
        }

        function dnd() { ShellState.dnd = !ShellState.dnd; }

        target: "hshell"
    }

}
