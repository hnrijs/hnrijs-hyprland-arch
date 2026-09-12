pragma Singleton
import QtQuick
import Quickshell
import qs
import Quickshell.Hyprland

Singleton {
    id: root
    property string panel: "clock"
    property string activeScreen: ""
    property string leftPanel: ""
    property string rightPanel: ""
    property string osd: ""
    property bool workspaceNotice: false
    property bool dnd: false
    property var notificationHistory: []
    property var liveNotifications: []
    property int nightLightTemperature: 4500
    property int keyboardNavigation: 0
    readonly property bool expanded: panel !== "clock"
    readonly property string scripts: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/scripts/"
    function currentScreen() {
        return Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : (Quickshell.screens.length ? Quickshell.screens[0].name : "");
    }
    function setPanel(name) {
        if (!["clock", "control", "launcher", "clipboard", "calendar", "wallpaper", "power", "menu", "overview", "auth"].includes(name))
            return;
        if (!expanded)
            activeScreen = currentScreen();
        leftPanel = "";
        rightPanel = "";
        keyboardNavigation = 0;
        panel = name;
    }
    function show(name) {
        if (name === "notifications")
            name = "control";
        if (name === "system" || name === "tools")
            name = "menu";
        setPanel(panel === name ? "clock" : name);
    }
    function showOnScreen(name, screenName) {
        setPanel(name);
        activeScreen = screenName;
    }
    function close() {
        if (panel === "auth")
            return;
        setPanel("clock");
    }
    function side(name, direction) {
        if (direction === "left") {
            leftPanel = leftPanel === name ? "" : name;
            rightPanel = "";
        } else {
            rightPanel = rightPanel === name ? "" : name;
            leftPanel = "";
        }
    }
    function showOsd(kind) {
        osd = kind;
        osdTimer.restart();
    }
    function rememberNotification(n) {
        notificationHistory = [
            {
                id: n.id,
                app: n.appName || "Notification",
                summary: n.summary || "",
                body: n.body || ""
            }
        ].concat(notificationHistory.filter(v => v.id !== n.id)).slice(0, 100);
    }
    function clearNotifications() {
        notificationHistory = [];
        liveNotifications.slice().forEach(n => n.dismiss());
    }
    function dismissNotification(id) {
        notificationHistory = notificationHistory.filter(n => n.id !== id);
        const found = liveNotifications.find(n => n.id === id);
        if (found)
            found.dismiss();
    }
    Timer {
        id: osdTimer
        interval: 3000
        onTriggered: root.osd = ""
    }
    Timer {
        id: workspaceTimer
        interval: 1800
        onTriggered: root.workspaceNotice = false
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.workspaceNotice = true;
            workspaceTimer.restart();
        }
    }
}
