import QtQuick
import qs
import qs.components

FocusScope {
    id: root
    implicitHeight: 400
    function takeInitialFocus() { dnd.forceActiveFocus(); }
    Column {
        anchors.fill: parent; spacing: 10
        Row {
            width: parent.width; spacing: 8
            ShellText { width: parent.width - 80; height: 32; text: "Notifications"; font.pixelSize: 16; verticalAlignment: Text.AlignVCenter }
            IconButton { id: dnd; width: 32; height: 32; icon: ShellState.dnd ? "󰂛" : "󰂚"; accessibleName: "Toggle do not disturb"; onClicked: ShellState.dnd = !ShellState.dnd }
            IconButton { width: 32; height: 32; icon: "×"; accessibleName: "Clear history"; onClicked: ShellState.notificationHistory = [] }
        }
        ShellText { text: ShellState.dnd ? "Do not disturb is on" : "Recent notifications · this session"; color: Style.muted; font.pixelSize: 10 }
        ListView {
            id: historyList
            width: parent.width; height: parent.height - 70; clip: true; spacing: 8
            model: ShellState.notificationHistory
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width; height: content.implicitHeight + 20; radius: Style.radiusSmall; color: Style.bg1
                Column {
                    id: content; x: 10; y: 10; width: parent.width - 20; spacing: 5
                    ShellText { width: parent.width; text: modelData.app; color: Style.muted; font.pixelSize: 10; elide: Text.ElideRight }
                    ShellText { width: parent.width; text: modelData.summary; textFormat: Text.PlainText; wrapMode: Text.Wrap; font.bold: true }
                    ShellText { width: parent.width; text: modelData.body; textFormat: Text.PlainText; wrapMode: Text.Wrap; color: Style.muted; maximumLineCount: 5; elide: Text.ElideRight }
                }
            }
            ShellText { anchors.centerIn: parent; visible: historyList.count === 0; text: "No notifications yet"; color: Style.muted }
        }
    }
}
