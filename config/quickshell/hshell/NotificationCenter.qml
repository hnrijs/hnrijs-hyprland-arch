pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    id: root
    property var current: null
    property string screenName: ""
    function present(notification) {
        const previous = current;
        current = null;
        if (previous && previous !== notification)
            previous.expire();
        if (!Preferences.notifications || ShellState.dnd) {
            notification.expire();
            return;
        }
        screenName = ShellState.currentScreen();
        current = notification;
        expiry.restart();
    }
    function dismissCurrent() {
        const old = current;
        current = null;
        expiry.stop();
        if (old)
            old.expire();
    }
    Timer {
        id: expiry
        interval: Math.round(Preferences.notificationSeconds * 1000)
        onTriggered: root.dismissCurrent()
    }
    Connections {
        target: ShellState
        function onDndChanged() {
            if (ShellState.dnd)
                root.dismissCurrent();
        }
    }
    Connections {
        target: root.current
        function onClosed(reason) {
            root.current = null;
            expiry.stop();
        }
    }
}
