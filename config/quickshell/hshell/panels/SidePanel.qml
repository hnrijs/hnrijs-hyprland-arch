import QtQuick
import qs

Loader {
    id: root
    required property string kind
    required property var shellWindow
    sourceComponent: ["wifi", "bluetooth", "audio", "microphone", "nightlight", "tray"].includes(kind) ? details : tools
    Component {
        id: details
        DetailsPanel {
            kind: root.kind
            shellWindow: root.shellWindow
        }
    }
    Component {
        id: tools
        ToolPanel {
            kind: root.kind
        }
    }
}
