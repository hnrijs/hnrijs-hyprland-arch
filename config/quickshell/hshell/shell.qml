import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

ShellRoot {
    id: root
    property bool authReady: Auth.registered
    NotificationServer {
        id: notifications
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
    Binding {
        target: ShellState
        property: "liveNotifications"
        value: notifications.trackedNotifications.values
    }
    NotificationPopups {
        notificationModel: notifications.trackedNotifications.values
        screen: Quickshell.screens.find(s => s.name === ShellState.currentScreen()) || Quickshell.screens[0] || null
    }
    LowBatteryMonitor {}
    SystemEvents {}
    Variants {
        model: Quickshell.screens
        Pill {
            required property var modelData
            screen: modelData
        }
    }
    IpcHandler {
        target: "hshell"
        function ping(): string {
            return "hshell";
        }
        function toggle(panel: string) {
            if (!Auth.active)
                ShellState.show(panel);
        }
        function close() {
            ShellState.close();
        }
        function dnd() {
            ShellState.dnd = !ShellState.dnd;
        }
        function osd(kind: string) {
            if (kind === "brightness")
                Backend.refreshStatus();
            if (["volume", "brightness"].includes(kind))
                ShellState.showOsd(kind);
        }
        function tool(name: string) {
            if (!Auth.active) {
                ShellState.setPanel("menu");
                ShellState.side(name, "left");
            }
        }
        function caffeine() {
            Tasks.caffeine.start(["caffeine", "toggle"]);
        }
    }
}
