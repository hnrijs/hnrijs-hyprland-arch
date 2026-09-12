import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import qs
import qs.components

Column {
    id: root
    required property var shellWindow
    spacing: 12
    Grid {
        width: parent.width
        columns: 3
        spacing: 8
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰤨  Wi-Fi"
            detail: Controls.connectedWifi ? Controls.connectedWifi.name : (Controls.wifiOn ? "Disconnected" : "Off")
            selected: !!Controls.connectedWifi
            onClicked: ShellState.side("wifi", "left")
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰕾  Audio"
            detail: Controls.sink ? (Controls.sink.audio.muted ? "Muted" : Controls.sink.description) : "No output"
            onClicked: ShellState.side("audio", "right")
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰂯  Bluetooth"
            detail: Controls.connectedDevices.length + " connected"
            selected: Controls.connectedDevices.length > 0
            onClicked: ShellState.side("bluetooth", "right")
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰁹  Power"
            detail: (Controls.hasBattery ? Math.round(Controls.batteryLevel * 100) + "% · " : "") + Backend.powerProfile
            onClicked: Backend.cyclePowerProfile()
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰍬  Microphone"
            detail: Controls.source ? (Controls.source.audio.muted ? "Muted" : "On · click to mute") : "Unavailable"
            selected: Controls.source && !Controls.source.audio.muted
            onClicked: Controls.mic()
            onPressAndHold: ShellState.side("microphone", "right")
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰅶  Caffeine"
            detail: Tasks.caffeine.result.enabled ? "Stay awake" : "Idle enabled"
            selected: !!Tasks.caffeine.result.enabled
            onClicked: Tasks.caffeine.start(["caffeine", "toggle"])
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰖔  Night light"
            detail: Backend.nightLightStatus
            selected: Backend.nightLightStatus === "on"
            onClicked: Backend.toggleNightLight()
            onPressAndHold: ShellState.side("nightlight", "left")
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰂛  Do not disturb"
            detail: ShellState.dnd ? "On" : "Off"
            selected: ShellState.dnd
            onClicked: ShellState.dnd = !ShellState.dnd
        }
        PillButton {
            width: (parent.width - 16) / 3
            text: "󰀻  Tray apps"
            detail: SystemTray.items.values.length + " apps"
            onClicked: ShellState.side("tray", "right")
        }
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
    Rectangle {
        width: parent.width
        height: media.implicitHeight + 28
        radius: 24
        color: Style.bg1
        Column {
            id: media
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 10
            Choice {
                visible: Mpris.players.values.length > 1
                width: parent.width
                model: Mpris.players.values.map(p => p.identity)
                currentIndex: Controls.playerIndex
                onActivated: Controls.playerIndex = currentIndex
            }
            Row {
                width: parent.width
                spacing: 12
                Image {
                    width: 64
                    height: 64
                    source: Controls.player ? Controls.player.trackArtUrl : ""
                    sourceSize: Qt.size(128, 128)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: source.toString() !== ""
                }
                Column {
                    width: parent.width - (Controls.player && Controls.player.trackArtUrl ? 76 : 0)
                    spacing: 6
                    BodyText {
                        width: parent.width
                        text: Controls.player ? (Controls.player.trackTitle || "Unknown track") : "No media playing"
                        font.pixelSize: 18
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    BodyText {
                        width: parent.width
                        text: Controls.player ? (Controls.player.trackArtist || Controls.player.identity) : "Open a player to use media controls"
                        color: Style.muted
                    }
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                PillButton {
                    width: 60
                    text: "󰒮"
                    enabled: Controls.player && Controls.player.canGoPrevious
                    onClicked: Controls.player.previous()
                }
                PillButton {
                    width: 100
                    text: Controls.player && Controls.player.isPlaying ? "󰏤" : "󰐊"
                    selected: true
                    enabled: Controls.player && Controls.player.canTogglePlaying
                    onClicked: Controls.player.togglePlaying()
                }
                PillButton {
                    width: 60
                    text: "󰒭"
                    enabled: Controls.player && Controls.player.canGoNext
                    onClicked: Controls.player.next()
                }
            }
            PillSlider {
                width: parent.width
                caption: "Seek"
                icon: "󰎆"
                enabled: Controls.player && Controls.player.canSeek && Controls.player.length > 0
                value: Controls.player && Controls.player.length > 0 ? Controls.player.position / Controls.player.length : 0
                displayValue: Controls.player ? Controls.duration(Controls.player.position) + " / " + Controls.duration(Controls.player.length) : "0:00"
                onMoved: if (Controls.player)
                    Controls.player.position = value * Controls.player.length
            }
            Timer {
                interval: 1000
                repeat: true
                running: root.visible && Controls.player && Controls.player.isPlaying
                onTriggered: if (Controls.player)
                    Controls.player.positionChanged()
            }
        }
    }
    Row {
        width: parent.width
        BodyText {
            width: parent.width - 120
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
