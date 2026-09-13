import QtQuick
import QtQuick.Controls
import qs
import qs.components

Column {
    id: root
    spacing: 12
    property string role: "browser"
    Task {
        id: apps
        Component.onCompleted: start(["default-apps", "list"])
    }
    Task {
        id: save
        onFinished: success => {
            if (success)
                apps.start(["default-apps", "list"]);
        }
    }
    Flow {
        width: parent.width
        spacing: 6
        Repeater {
            model: [["browser", "Browser"], ["video", "Media"], ["image", "Images"], ["files", "Files"], ["text", "Text"], ["terminal", "Terminal"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 12) / 3
                text: modelData[1]
                selected: root.role === modelData[0]
                onClicked: root.role = modelData[0]
            }
        }
    }
    Field {
        id: query
        width: parent.width
        placeholderText: "Find installed application…"
    }
    ListView {
        width: parent.width
        height: Math.min(320, contentHeight)
        spacing: 6
        clip: true
        model: (apps.result.apps || []).filter(a => (root.role !== "terminal" || a.terminal) && String(a.name + a.id).toLowerCase().includes(query.text.toLowerCase()))
        ScrollBar.vertical: ScrollBar {}
        delegate: PillButton {
            required property var modelData
            width: ListView.view.width
            text: modelData.name
            selected: !!apps.result.defaults && apps.result.defaults[root.role] === modelData.id
            enabled: !save.running
            onClicked: save.start(["default-apps", "set", root.role, modelData.id])
        }
    }
    TaskStatus {
        width: parent.width
        task: save
    }
    TaskStatus {
        width: parent.width
        task: apps
    }
}
