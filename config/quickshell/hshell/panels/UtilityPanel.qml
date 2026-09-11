import QtQuick
import Quickshell
import qs
import qs.components

FocusScope {
    id: root
    property string category: "tools"
    readonly property string title: category === "system" ? "System" : category === "web" ? "Web" : category === "emoji" ? "Emoji" : "Tools"
    readonly property var entries: Utilities.entries.filter(entry => entry.category === category && (entry.title + " " + entry.subtitle).toLowerCase().includes(search.text.toLowerCase()))
    implicitHeight: 410
    function takeInitialFocus() { search.forceActiveFocus(); }
    Column {
        anchors.fill: parent
        spacing: 10
        ShellText { text: root.title; font.pixelSize: 16; font.bold: true }
        Rectangle {
            width: parent.width; height: 38; radius: Style.radiusSmall
            color: Style.bg1; border.color: search.activeFocus ? Style.foreground : Style.bg3; border.width: 1
            TextInput {
                id: search
                anchors.fill: parent; anchors.margins: 10
                color: Style.foreground; font.family: Style.fontFamily; font.pixelSize: 12
                clip: true; selectByMouse: true
                onTextChanged: actions.currentIndex = 0
                Keys.onDownPressed: { actions.forceActiveFocus(); actions.currentIndex = 0; }
                Keys.onReturnPressed: if (root.entries.length) Utilities.run(root.entries[0])
                ShellText { visible: !search.text; text: "Search…"; color: Style.mutedDark }
            }
        }
        ListView {
            id: actions
            width: parent.width; height: parent.height - 80
            clip: true; spacing: 6; model: root.entries
            keyNavigationEnabled: true
            Keys.onReturnPressed: if (currentIndex >= 0 && currentIndex < root.entries.length) Utilities.run(root.entries[currentIndex])
            Keys.onEnterPressed: if (currentIndex >= 0 && currentIndex < root.entries.length) Utilities.run(root.entries[currentIndex])
            delegate: ActionTile {
                required property var modelData
                required property int index
                width: actions.width
                title: modelData.title; subtitle: modelData.subtitle; icon: modelData.icon
                active: actions.activeFocus && actions.currentIndex === index
                onClicked: Utilities.run(modelData)
            }
            ShellText { anchors.centerIn: parent; visible: actions.count === 0; text: "No matching tools"; color: Style.muted }
        }
    }
}
