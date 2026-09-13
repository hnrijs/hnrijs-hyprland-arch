import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    property var result: ({})
    property var progress: ({})
    property string error: ""
    readonly property bool running: process.running
    signal finished(bool success)
    function start(args) {
        if (process.running)
            return;
        error = "";
        progress = ({});
        process.exec(["python3", (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/scripts/hshell-task.py"].concat(args));
    }
    function cancel() {
        process.signal(15);
    }
    Process {
        id: process
        stdout: SplitParser {
            onRead: data => {
                try {
                    const event = JSON.parse(data);
                    if (event.type === "result")
                        root.result = event.data;
                    else if (event.type === "progress")
                        root.progress = event.data;
                    else if (event.type === "error")
                        root.error = String(event.data);
                } catch (error) { /* Non-JSON subprocess output is not application state. */ }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim())
                root.error = text.trim()
        }
        onExited: code => {
            if (code !== 0 && !root.error)
                root.error = "Task stopped (" + code + ")";
            root.finished(code === 0);
        }
    }
}
