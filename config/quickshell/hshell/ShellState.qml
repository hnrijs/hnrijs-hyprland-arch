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
    property string toolName: ""
    property string detailName: ""
    property string returnPanel: "menu"
    readonly property string workspaceText: "Workspace " + (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1)
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
        if (!["clock", "control", "launcher", "clipboard", "calendar", "wallpaper", "power", "menu", "overview", "auth", "tool", "detail", "tools", "settings", "emoji", "color", "web"].includes(name))
            return;
        if (!expanded)
            activeScreen = currentScreen();
        leftPanel = "";
        rightPanel = "";
        workspaceNotice = false;
        osd = "";
        keyboardNavigation = 0;
        panel = name;
    }
    function show(name) {
        if (name === "notifications")
            name = "control";
        if (name === "system")
            name = "settings";
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
        if (["wifi", "bluetooth", "audio", "microphone", "nightlight", "tray"].includes(name)) {
            detailName = name;
            returnPanel = "control";
            setPanel("detail");
            if (direction === "left")
                leftPanel = name;
            else
                rightPanel = name;
        } else {
            toolName = name;
            returnPanel = panel === "settings" ? "settings" : "tools";
            setPanel("tool");
        }
    }
    function back() {
        if (panel === "auth")
            return;
        if (panel === "tool" || panel === "detail")
            setPanel(returnPanel);
        else if (panel === "tools" || panel === "settings")
            setPanel("menu");
        else
            close();
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
        interval: 1400
        onTriggered: root.osd = ""
    }
    Timer {
        id: workspaceTimer
        interval: 1000
        onTriggered: root.workspaceNotice = false
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (root.panel !== "auth")
                root.close();
            root.osd = "";
            root.workspaceNotice = true;
            workspaceTimer.restart();
        }
    }
}
