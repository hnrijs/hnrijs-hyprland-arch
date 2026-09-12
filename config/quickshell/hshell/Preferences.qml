pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    id: root
    property string theme: "mocha"
    property string city: "Riga"
    property bool syncLogin: true
    property var pending: []
    function save(key, value) {
        if (key === "theme")
            theme = value;
        if (key === "city")
            city = value;
        if (key === "syncLogin")
            syncLogin = value === "true";
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
            root.theme = result.theme || "mocha";
            root.city = result.city || "Riga";
            root.syncLogin = result.syncLogin !== "false" && result.syncLogin !== false;
        }
    }
    Task {
        id: writer
        onFinished: success => Qt.callLater(root.flush)
    }
    Component.onCompleted: reader.start(["preferences"])
}
