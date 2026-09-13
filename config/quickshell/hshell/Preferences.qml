pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    id: root
    property bool visualizer: true
    property bool hoverExpand: true
    property bool mediaCard: true
    property bool tray: true
    property bool notifications: true
    property bool weather: true
    property bool hideFullscreen: true
    property bool workspaceOsd: true
    property bool volumeOsd: true
    property bool showPower: true
    property bool showMic: true
    property bool showIdle: true
    property bool showNightlight: true
    property bool showBluetooth: true
    property bool showWifi: true
    property real notificationSeconds: 3
    property string wallpaperFolder: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string backgroundColor: "#080808"
    property string surfaceColor: "#202020"
    property string foregroundColor: "#ffffff"
    property string accentColor: "#ffffff"
    property string city: "Riga"
    property var pending: []
    property string writingKey: ""
    function save(key, value) {
        if (["visualizer", "hoverExpand", "mediaCard", "tray", "notifications", "weather", "hideFullscreen", "workspaceOsd", "volumeOsd", "showPower", "showMic", "showIdle", "showNightlight", "showBluetooth", "showWifi"].includes(key))
            root[key] = value === "true";
        if (["wallpaperFolder", "backgroundColor", "surfaceColor", "foregroundColor", "accentColor"].includes(key))
            root[key] = value;
        if (key === "notificationSeconds")
            notificationSeconds = Math.max(0.1, Math.min(10, Number(value)));
        if (key === "city")
            city = value;
        pending = pending.concat([[key, value]]);
        flush();
    }
    function flush() {
        if (writer.running || pending.length === 0)
            return;
        const item = pending[0];
        pending = pending.slice(1);
        writingKey = item[0];
        writer.start(["preference", item[0], item[1]]);
    }
    Task {
        id: reader
        onFinished: success => {
            if (!success)
                return;
            ["visualizer", "hoverExpand", "mediaCard", "tray", "notifications", "weather", "hideFullscreen", "workspaceOsd", "volumeOsd", "showPower", "showMic", "showIdle", "showNightlight", "showBluetooth", "showWifi"].forEach(k => root[k] = result[k] !== "false" && result[k] !== false);
            root.city = result.city || "Riga";
            root.notificationSeconds = Math.max(0.1, Math.min(10, Number(result.notificationSeconds || 3)));
            ["wallpaperFolder", "backgroundColor", "surfaceColor", "foregroundColor", "accentColor"].forEach(k => {
                if (result[k])
                    root[k] = result[k];
            });
        }
    }
    Task {
        id: writer
        onFinished: success => {
            if (success && root.writingKey === "wallpaperFolder")
                WallpaperState.refreshWallpapers();
            Qt.callLater(root.flush);
        }
    }
    Component.onCompleted: reader.start(["preferences"])
}
