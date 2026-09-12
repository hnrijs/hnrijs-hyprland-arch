import QtQuick
import QtQuick.Controls
import qs

Column {
    id: root
    objectName: "inlineChoice"
    property var model: []
    property int currentIndex: 0
    readonly property string currentText: model.length ? String(model[currentIndex]) : ""
    property bool opened: false
    signal activated(int index)
    spacing: 6
    PillButton {
        objectName: "choiceToggle"
        width: parent.width
        text: root.currentText + (root.opened ? "  ▴" : "  ▾")
        onClicked: root.opened = !root.opened
    }
    Column {
        width: parent.width
        visible: root.opened
        spacing: 4
        Repeater {
            model: root.opened ? root.model : []
            delegate: PillButton {
                objectName: "choiceOption-" + index
                required property int index
                required property var modelData
                width: parent.width
                text: String(modelData)
                selected: root.currentIndex === index
                onClicked: {
                    root.currentIndex = index;
                    root.activated(index);
                    root.opened = false;
                }
            }
        }
    }
}
