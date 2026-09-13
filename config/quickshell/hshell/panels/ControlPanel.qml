import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs
import qs.components

Column {
    id: root
    required property var shellWindow
    spacing: 12
    GridLayout {
        width: parent.width
        columns: 3
        rowSpacing: 10
        columnSpacing: 10
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰤨"
            text: "Wi-Fi"
            detail: Controls.connectedWifi ? Controls.connectedWifi.name : Controls.wifiOn ? "Disconnected" : "Off"
            selected: Controls.wifiOn
            onClicked: Controls.wifi()
            onSecondaryClicked: ShellState.side("wifi", "left")
            visible: Preferences.showWifi
        }
        ControlTile {
            Layout.columnSpan: Preferences.showWifi ? 2 : 3
            Layout.fillWidth: true
            symbol: "󰕾"
            text: "Audio"
            detail: Controls.sink ? Controls.sink.description : "No output"
            selected: Controls.sink && !Controls.sink.audio.muted
            onClicked: Controls.mute()
            onSecondaryClicked: ShellState.side("audio", "right")
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰂯"
            text: "Bluetooth"
            detail: Controls.connectedDevices.length + " connected"
            selected: Controls.adapter && Controls.adapter.enabled
            onClicked: Controls.bluetooth()
            onSecondaryClicked: ShellState.side("bluetooth", "right")
            visible: Preferences.showBluetooth
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "⊖"
            text: "Peace"
            detail: ShellState.dnd ? "On" : "Off"
            selected: ShellState.dnd
            onClicked: ShellState.dnd = !ShellState.dnd
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰖔"
            text: "Night light"
            detail: Backend.nightLightStatus
            selected: Backend.nightLightStatus === "on"
            onClicked: Backend.toggleNightLight()
            onSecondaryClicked: ShellState.side("nightlight", "left")
            visible: Preferences.showNightlight
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰁹"
            text: "Power"
            detail: Backend.powerProfile
            visible: Preferences.showPower
            onClicked: Backend.cyclePowerProfile()
            onSecondaryClicked: ShellState.side("powerprofile", "right")
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰍬"
            text: "Mic"
            detail: Controls.source && !Controls.source.audio.muted ? "On" : "Muted"
            selected: Controls.source && !Controls.source.audio.muted
            onClicked: Controls.mic()
            onSecondaryClicked: ShellState.side("microphone", "right")
            visible: Preferences.showMic
        }
        ControlTile {
            Layout.fillWidth: true
            Layout.preferredWidth: 180
            symbol: "󰅶"
            text: "Caffeine"
            detail: Tasks.caffeine.result.enabled ? "Stay awake" : "Automatic"
            visible: Preferences.showIdle
            selected: !!Tasks.caffeine.result.enabled
            onClicked: Tasks.caffeine.start(["caffeine", "toggle"])
        }
    }
    TrayRow {
        visible: Preferences.tray && implicitHeight > 0
        width: parent.width
        shellWindow: root.shellWindow
    }
    PillSlider {
        width: parent.width
        icon: "󰕾"
        caption: "Volume"
        enabled: !!Controls.sink
        value: Controls.sink && Controls.sink.audio ? Controls.sink.audio.volume : 0
        onMoved: Controls.volume(value)
    }
    PillSlider {
        id: brightnessSlider
        width: parent.width
        enabled: Backend.brightnessAvailable
        icon: "󰃠"
        caption: "Brightness"
        value: Backend.brightness / 100
        displayValue: Backend.brightnessAvailable ? Math.round(value * 100) + "%" : "Unavailable"
        onMoved: Backend.setBrightness(value * 100)
    }
    MediaCard {
        visible: Preferences.mediaCard && !!Media.player
        width: parent.width
    }
    Row {
        width: parent.width
        BodyText {
            width: parent.width - 120
            height: 44
            verticalAlignment: Text.AlignVCenter
            text: "Notifications"
            font.pixelSize: 16
        }
        PillButton {
            width: 120
            text: "Clear all"
            onClicked: ShellState.clearNotifications()
        }
    }
    BodyText {
        visible: ShellState.notificationHistory.length === 0
        text: "All caught up"
        color: Style.muted
    }
    Repeater {
        model: ShellState.notificationHistory
        delegate: Rectangle {
            required property var modelData
            width: root.width
            height: notice.implicitHeight + 28
            radius: 22
            color: Style.bg1
            Column {
                id: notice
                x: 14
                y: 14
                width: parent.width - 68
                spacing: 5
                BodyText {
                    width: parent.width
                    text: modelData.app
                    color: Style.primary
                }
                BodyText {
                    width: parent.width
                    text: modelData.summary
                    font.bold: true
                }
                BodyText {
                    width: parent.width
                    text: modelData.body
                    color: Style.muted
                    maximumLineCount: 5
                    elide: Text.ElideRight
                }
                Flow {
                    width: parent.width
                    spacing: 5
                    Repeater {
                        model: {
                            const n = ShellState.liveNotifications.find(n => n.id === modelData.id);
                            return n ? n.actions : [];
                        }
                        delegate: PillButton {
                            required property var modelData
                            width: 140
                            text: modelData.text
                            onClicked: modelData.invoke()
                        }
                    }
                }
            }
            PillButton {
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 8
                }
                width: 40
                text: "×"
                onClicked: ShellState.dismissNotification(modelData.id)
            }
        }
    }
}
