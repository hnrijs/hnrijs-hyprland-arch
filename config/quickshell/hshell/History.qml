pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    id: root
    property var entries: ({
            colors: [],
            speed: [],
            ip: []
        })
    property var pending: []
    function reload() {
        pending = pending.concat([["history"]]);
        flush();
    }
    function clear(kind) {
        pending = pending.concat([["history-clear", kind]]);
        flush();
    }
    function append(kind, result) {
        pending = pending.concat([["history-add", kind, JSON.stringify(result)]]);
        flush();
    }
    function flush() {
        if (task.running || !pending.length)
            return;
        const args = pending[0];
        pending = pending.slice(1);
        task.start(args);
    }
    Task {
        id: task
        onFinished: success => {
            if (success)
                root.entries = result;
            Qt.callLater(root.flush);
        }
    }
    Component.onCompleted: reload()
}
