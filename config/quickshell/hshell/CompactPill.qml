import QtQuick
import Quickshell
import qs
import qs.components

Item {
    id: root
    required property string screenName
    property bool hovered: false
    readonly property bool playing: !!Media.player && Media.player.isPlaying
    readonly property bool showBars: Preferences.visualizer && playing
    readonly property bool notice: ShellState.workspaceNotice
    readonly property bool hardwareOsd: ShellState.osd !== "" && !notice
    readonly property real desiredWidth: notice ? 218 : hardwareOsd ? 260 : hovered ? 620 : root.showBars ? 170 : 140
    readonly property real desiredHeight: hovered && !notice && !hardwareOsd ? 86 : 42
    height: desiredHeight
    onVisibleChanged: if (!visible) {
        leave.stop();
        hovered = false;
    }
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                leave.stop();
                root.hovered = Preferences.hoverExpand;
            } else
                leave.restart();
        }
    }
    Timer {
        id: leave
        interval: 200
        onTriggered: root.hovered = false
    }
    Text {
        anchors.centerIn: parent
        visible: root.notice
        text: ShellState.workspaceText
        color: Style.foreground
        font.family: Style.iconFontFamily
        font.pixelSize: 16
    }
    Item {
        anchors.fill: parent
        visible: !root.notice && !root.hardwareOsd
        AudioSpectrum {
            x: 18
            y: 13
            width: 24
            height: 16
            active: root.visible && root.showBars && !root.hovered && ShellState.currentScreen() === root.screenName
            visible: !root.hovered && root.showBars
        }
        Item {
            x: root.hovered ? (parent.width - width) / 2 : (parent.width - width) / 2 + (root.showBars ? 12 : 0)
            width: root.hovered ? 158 : 96
            height: parent.height
            Column {
                anchors.centerIn: parent
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    font.family: Style.iconFontFamily
                    font.pixelSize: root.hovered ? 24 : 18
                    font.bold: true
                    color: Style.foreground
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.hovered
                    text: Qt.formatDateTime(clock.date, "ddd, MMM d")
                    font.family: Style.iconFontFamily
                    font.pixelSize: 12
                    color: Style.muted
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => ShellState.showOnScreen(event.button === Qt.RightButton ? "menu" : event.button === Qt.MiddleButton ? "calendar" : "control", root.screenName)
            }
        }
        Item {
            x: 16
            y: 16
            width: 210
            height: 54
            visible: root.hovered
            Rectangle {
                width: 54
                height: 54
                radius: 16
                color: Style.bg1
                clip: true
                Image {
                    anchors.fill: parent
                    source: Media.player ? Media.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
                Text {
                    anchors.centerIn: parent
                    visible: !Media.player || !Media.player.trackArtUrl
                    text: "󰎈"
                    color: Style.foreground
                    font.family: Style.iconFontFamily
                    font.pixelSize: 22
                }
            }
            AudioSpectrum {
                visible: root.showBars
                x: 64
                y: 4
                width: 24
                height: 14
                active: root.visible && root.showBars && root.hovered && ShellState.currentScreen() === root.screenName
            }
            Text {
                x: root.showBars ? 98 : 64
                y: 1
                width: root.showBars ? 112 : 146
                height: 22
                text: Media.player ? Media.player.trackTitle || "Audio" : "Audio"
                color: Style.foreground
                font.family: Style.iconFontFamily
                font.pixelSize: 13
                elide: Text.ElideRight
            }
            Text {
                x: 64
                y: 30
                width: 146
                text: Media.player ? Media.player.trackArtist : "No player"
                color: Style.muted
                font.family: Style.iconFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            MouseArea {
                anchors.fill: parent
                onClicked: ShellState.showOnScreen("control", root.screenName)
            }
        }
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            width: 112
            height: 44
            radius: 20
            color: Style.bg1
            visible: root.hovered
            Text {
                anchors.centerIn: parent
                text: (Controls.connectedWifi ? "󰤨" : "󰤭") + "  " + (Controls.hasBattery ? Math.round(Controls.batteryLevel * 100) + "%" : "󰕾")
                color: Style.foreground
                font.family: Style.iconFontFamily
                font.pixelSize: 17
            }
            MouseArea {
                anchors.fill: parent
                onClicked: ShellState.showOnScreen("control", root.screenName)
            }
        }
    }
    ThinSlider {
        x: 10
        y: 7
        width: parent.width - 20
        compact: true
        visible: root.hardwareOsd
        property string kind: ShellState.osd
        enabled: kind === "volume" ? !!Controls.sink : Backend.brightnessAvailable
        icon: kind === "volume" ? "󰕾" : "󰃠"
        caption: kind
        value: kind === "volume" ? (Controls.sink ? Controls.sink.audio.volume : 0) : Backend.brightness / 100
        displayValue: !enabled ? "N/A" : kind === "volume" && Controls.sink.audio.muted ? "Mute" : Math.round(value * 100) + "%"
        onMoved: {
            if (kind === "volume")
                Controls.volume(value);
            else
                Backend.setBrightness(value * 100);
        }
    }
}
