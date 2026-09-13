import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import qs
import qs.components

Column {
    id: root
    property int section: 0
    spacing: 14
    Row {
        width: parent.width
        spacing: 8
        Repeater {
            model: ["Pill", "Controls", "Colors"]
            delegate: PillButton {
                required property string modelData
                required property int index
                width: (parent.width - 16) / 3
                text: modelData
                selected: root.section === index
                onClicked: root.section = index
            }
        }
    }
    Flow {
        visible: root.section === 0
        width: parent.width
        spacing: 8
        Repeater {
            model: [["visualizer", "󰎈", "Cava"], ["hoverExpand", "󰆽", "Pill Hover"], ["hideFullscreen", "󰊓", "Fullscreen Hide"], ["mediaCard", "󰐊", "Media Player"], ["tray", "󰀻", "Tray Icons"], ["notifications", "󰂚", "Notifications"], ["workspaceOsd", "󰕮", "Workspace OSD"], ["volumeOsd", "󰕾", "Volume OSD"], ["weather", "󰖐", "Weather"]]
            delegate: ControlTile {
                required property var modelData
                width: (parent.width - 8) / 2
                text: modelData[2]
                symbol: modelData[1]
                selected: Preferences[modelData[0]]
                detail: selected ? "On" : "Off"
                onClicked: Preferences.save(modelData[0], selected ? "false" : "true")
            }
        }
    }
    BodyText {
        visible: root.section === 0
        text: "Notification Duration · " + Preferences.notificationSeconds.toFixed(1) + " s"
    }
    ThinSlider {
        visible: root.section === 0
        width: parent.width
        icon: "󰔛"
        value: (Preferences.notificationSeconds - 0.1) / 9.9
        displayValue: Preferences.notificationSeconds.toFixed(1) + " s"
        onMoved: {
            Preferences.notificationSeconds = Math.round((value * 9.9 + 0.1) * 10) / 10;
            durationCommit.restart();
        }
    }
    Timer {
        id: durationCommit
        interval: 300
        onTriggered: Preferences.save("notificationSeconds", String(Preferences.notificationSeconds))
    }
    BodyText {
        visible: root.section === 1
        text: "Control Center"
    }
    Flow {
        visible: root.section === 1
        width: parent.width
        spacing: 8
        Repeater {
            model: [["showWifi", "Wi-Fi"], ["showBluetooth", "Bluetooth"], ["showNightlight", "Night Light"], ["showPower", "Power Profile"], ["showMic", "Microphone"], ["showIdle", "Caffeine"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 8) / 2
                text: modelData[1]
                selected: Preferences[modelData[0]]
                onClicked: Preferences.save(modelData[0], selected ? "false" : "true")
            }
        }
    }
    BodyText {
        visible: root.section === 2
        text: "Colors"
    }
    Repeater {
        model: [["backgroundColor", "Background"], ["surfaceColor", "Surfaces"], ["foregroundColor", "Text"], ["accentColor", "Accent"]]
        delegate: Row {
            visible: root.section === 2
            required property var modelData
            width: parent.width
            spacing: 10
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: Preferences[modelData[0]]
                border.width: 1
                border.color: Style.muted
            }
            BodyText {
                width: 110
                height: 44
                verticalAlignment: Text.AlignVCenter
                text: modelData[1]
            }
            Field {
                width: parent.width - 166
                text: Preferences[parent.modelData[0]]
                maximumLength: 7
                onEditingFinished: if (/^#[0-9a-fA-F]{6}$/.test(text))
                    Preferences.save(parent.modelData[0], text)
            }
        }
    }
    PillButton {
        visible: root.section === 2
        text: "Reset Colors"
        onClicked: {
            Preferences.save("backgroundColor", "#080808");
            Preferences.save("surfaceColor", "#202020");
            Preferences.save("foregroundColor", "#ffffff");
            Preferences.save("accentColor", "#ffffff");
        }
    }
    BodyText {
        visible: root.section === 1
        text: "Wallpaper Folder"
    }
    Field {
        width: parent.width
        visible: root.section === 1
        text: Preferences.wallpaperFolder
        onEditingFinished: Preferences.save("wallpaperFolder", text)
    }
    BodyText {
        visible: root.section === 0
        text: "Weather City"
    }
    Field {
        width: parent.width
        visible: root.section === 0
        text: Preferences.city
        onEditingFinished: Preferences.save("city", text.trim() || "Riga")
    }
}
