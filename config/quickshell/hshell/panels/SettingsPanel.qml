import QtQuick
import qs
import qs.components

Column {
    spacing: 12
    BodyText {
        text: "Interface"
        font.pixelSize: 17
    }
    Repeater {
        model: [["visualizer", "Cava visualizer"], ["hoverExpand", "Expand pill on hover"], ["hideFullscreen", "Hide pill in fullscreen"], ["mediaCard", "Media player"], ["tray", "Tray icons"], ["notifications", "Notification popups"], ["workspaceOsd", "Workspace indicator"], ["volumeOsd", "Volume and brightness indicator"], ["weather", "Calendar weather"]]
        delegate: CheckToggle {
            required property var modelData
            width: parent.width
            text: modelData[1]
            checked: Preferences[modelData[0]]
            onToggled: Preferences.save(modelData[0], checked ? "true" : "false")
        }
    }
    BodyText {
        text: "Control center"
        font.pixelSize: 17
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: [["showWifi", "Wi-Fi"], ["showBluetooth", "Bluetooth"], ["showNightlight", "Night light"], ["showPower", "Power profile"], ["showMic", "Microphone"], ["showIdle", "Caffeine"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 16) / 3
                text: modelData[1]
                selected: Preferences[modelData[0]]
                onClicked: Preferences.save(modelData[0], Preferences[modelData[0]] ? "false" : "true")
            }
        }
    }
    BodyText {
        text: "Weather city"
    }
    Field {
        width: parent.width
        text: Preferences.city
        onEditingFinished: Preferences.save("city", text.trim() || "Riga")
    }
    PillButton {
        width: parent.width
        text: "Default applications"
        onClicked: ShellState.side("defaults", "left")
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: [["config", "Hyprland"], ["account", "Account"], ["update", "Update"], ["clean", "Clean"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 8) / 2
                text: modelData[1]
                onClicked: ShellState.side(modelData[0], "left")
            }
        }
    }
}
