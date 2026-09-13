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
    property string city: "Riga"
    property var pending: []
    function save(key, value) {
        if (["visualizer", "hoverExpand", "mediaCard", "tray", "notifications", "weather", "hideFullscreen", "workspaceOsd", "volumeOsd", "showPower", "showMic", "showIdle", "showNightlight", "showBluetooth", "showWifi"].includes(key))
            root[key] = value === "true";
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
        writer.start(["preference", item[0], item[1]]);
    }
    Task {
        id: reader
        onFinished: success => {
            if (!success)
                return;
            ["visualizer", "hoverExpand", "mediaCard", "tray", "notifications", "weather", "hideFullscreen", "workspaceOsd", "volumeOsd", "showPower", "showMic", "showIdle", "showNightlight", "showBluetooth", "showWifi"].forEach(k => root[k] = result[k] !== "false" && result[k] !== false);
            root.city = result.city || "Riga";
        }
    }
    Task {
        id: writer
        onFinished: success => Qt.callLater(root.flush)
    }
    Component.onCompleted: reader.start(["preferences"])
}
