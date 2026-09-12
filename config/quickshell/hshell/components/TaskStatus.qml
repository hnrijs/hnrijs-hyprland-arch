import QtQuick
import QtQuick.Controls
import qs

Column {
    required property var task
    spacing: 8
    Meter {
        width: parent.width
        visible: parent.task.running
        indeterminate: true
    }
    BodyText {
        width: parent.width
        visible: text !== ""
        text: parent.task.error || parent.task.progress.message || parent.task.result.message || ""
        color: parent.task.error ? Style.primary : Style.muted
        maximumLineCount: 8
        elide: Text.ElideLeft
    }
    PillButton {
        visible: parent.task.running
        text: "Cancel"
        onClicked: parent.task.cancel()
    }
}
