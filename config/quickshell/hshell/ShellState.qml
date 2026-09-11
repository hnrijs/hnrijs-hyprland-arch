import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
pragma Singleton

Singleton {
    id: root

    readonly property var panelWidths: ({
        "notifications": 500,
        "calendar": 400,
        "emoji": 420,
        "web": 500,
        "tools": 500,
        "system": 500,
        "control": 520,
        "launcher": 410,
        "clipboard": 365,
        "notes": 500,
        "wallpaper": 500,
        "power": 380
    })
    readonly property var panelHeights: ({
        "notifications": 400,
        "calendar": 294,
        "emoji": 410,
        "web": 410,
        "tools": 410,
        "system": 410,
        "control": 386,
        "launcher": 290,
        "clipboard": 80,
        "notes": 430,
        "wallpaper": 382,
        "power": 56
    })
    property string activeScreen: ""
    property bool dnd: false
    property var notificationHistory: []
    function rememberNotification(notification) {
        notificationHistory = [{app: notification.appName || "Notification", summary: notification.summary || "", body: notification.body || ""}].concat(notificationHistory).slice(0, 100);
    }
    property string panel: "clock"
    readonly property bool expanded: panel !== "clock"
    readonly property int targetWidth: expanded ? panelWidths[panel] : 145
    property alias nightLightTemperature: persistence.nightLightTemperature

    function setPanel(name) {
        if (name !== "clock" && panelWidths[name] === undefined) return;
        if (name !== "clock" && !expanded)
            activeScreen = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : (Quickshell.screens.length ? Quickshell.screens[0].name : "");
        panel = name;
    }
    function showOnScreen(name, screenName) {
        if (name !== "clock" && panelWidths[name] === undefined) return;
        activeScreen = screenName;
        panel = name;
    }

    function show(name) {
        if (name !== "clock" && panelWidths[name] === undefined)
            return ;

        setPanel(panel === name ? "clock" : name);
    }

    function close() {
        setPanel("clock");
    }

    function cycle(offset) {
        const panels = ["clock", "control", "launcher", "clipboard", "notes", "wallpaper", "system", "tools", "calendar", "notifications", "power"];
        const current = Math.max(0, panels.indexOf(panel));
        setPanel(panels[(current + offset + panels.length) % panels.length]);
    }

    PersistentProperties {
        id: persistence

        property int nightLightTemperature: 4500

        reloadableId: "hshell-state"
    }

}
