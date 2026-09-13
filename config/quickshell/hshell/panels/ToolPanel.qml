import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs
import qs.components

Column {
    id: root
    required property string kind
    onVisibleChanged: if (visible && (kind === "speed" || kind === "ip"))
        History.reload()
    spacing: 10
    function terminal(action) {
        Quickshell.execDetached(["alacritty", "-e", "bash", ShellState.scripts + "tools.sh", "terminal", action]);
    }
    function refresh() {
        if (kind === "disks")
            Tasks.disks.start(["disks"]);
    }
    Component.onCompleted: refresh()
    onKindChanged: refresh()
    Loader {
        width: parent.width
        height: item ? item.implicitHeight : 0
        sourceComponent: root.kind === "interface" ? interfaceSettings : root.kind === "system" ? systemSettings : root.kind === "network" ? networkSettings : root.kind === "calculator" ? calculator : root.kind === "color" ? color : root.kind === "exif" ? exif : root.kind === "disks" ? disks : root.kind === "speed" ? speed : root.kind === "download" ? download : root.kind === "media" ? media : root.kind === "ip" ? ip : root.kind === "emoji" ? emoji : root.kind === "periodic" ? periodic : settings
    }
    Component {
        id: disks
        Column {
            spacing: 10
            PillButton {
                width: parent.width
                text: "Refresh disks"
                enabled: !Tasks.disks.running
                onClicked: Tasks.disks.start(["disks"])
            }
            TaskStatus {
                width: parent.width
                task: Tasks.disks
            }
            Repeater {
                model: Tasks.disks.result.disks || []
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: dc.implicitHeight + 24
                    radius: 18
                    color: Style.bg1
                    Column {
                        id: dc
                        x: 12
                        y: 12
                        width: parent.width - 24
                        spacing: 8
                        BodyText {
                            width: parent.width
                            text: (modelData.label || modelData.model || modelData.name) + " · " + (modelData.size / 1073741824).toFixed(1) + " GiB"
                        }
                        BodyText {
                            width: parent.width
                            text: modelData.mountpoint || modelData.name
                            color: Style.muted
                        }
                        Meter {
                            width: parent.width
                            visible: !!modelData.total
                            value: modelData.total ? modelData.used / modelData.total : 0
                        }
                        BodyText {
                            visible: !!modelData.total
                            text: (modelData.free / 1073741824).toFixed(1) + " GiB free"
                        }
                        PillButton {
                            width: parent.width
                            visible: !!modelData.fstype && modelData.mountpoint !== "/"
                            text: modelData.mountpoint ? "Unmount" : "Mount"
                            enabled: !Tasks.disks.running
                            onClicked: Tasks.disks.start([modelData.mountpoint ? "unmount" : "mount", modelData.name])
                        }
                    }
                }
            }
        }
    }
    Component {
        id: speed
        Column {
            spacing: 16
            Rectangle {
                width: Math.min(parent.width, 260)
                anchors.horizontalCenter: parent.horizontalCenter
                height: width
                radius: width / 2
                color: Style.bg1
                border.color: Style.primary
                border.width: 3
                Column {
                    anchors.centerIn: parent
                    width: parent.width - 28
                    spacing: 10
                    BodyText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: Tasks.speed.running ? (Tasks.speed.progress.phase || "Connecting…") : "Speed Test"
                        color: Style.primary
                    }
                    BodyText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 34
                        text: Number((Tasks.speed.running ? Tasks.speed.progress.download : Tasks.speed.result.download) || 0).toFixed(1)
                    }
                    BodyText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "Mbps download"
                    }
                    BodyText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: Number((Tasks.speed.running ? Tasks.speed.progress.upload : Tasks.speed.result.upload) || 0).toFixed(1) + " Mbps upload"
                    }
                    BodyText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: Number((Tasks.speed.running ? Tasks.speed.progress.ping : Tasks.speed.result.ping) || 0).toFixed(0) + " ms ping"
                    }
                }
            }
            BodyText {
                width: parent.width
                text: Tasks.speed.result.server || "Values update after each measurement phase."
                color: Style.muted
            }
            PillButton {
                width: parent.width
                text: Tasks.speed.running ? "Stop" : "Start"
                onClicked: Tasks.speed.running ? Tasks.speed.cancel() : Tasks.speed.start(["speed"])
            }
            TaskStatus {
                width: parent.width
                task: Tasks.speed
                showCancel: false
            }
            HistoryList {
                width: parent.width
                kind: "speed"
            }
        }
    }
    Component {
        id: download
        Column {
            spacing: 10
            BodyText {
                width: parent.width
                text: "Download video, audio, files or repositories. Completion appears in notifications."
                color: Style.muted
            }
            Choice {
                id: format
                width: parent.width
                model: ["MP4", "MP3", "File", "Magnet", "HTML", "Git"]
            }
            Field {
                id: url
                width: parent.width
                placeholderText: "https://… or magnet:…"
            }
            Field {
                id: directory
                width: parent.width
                text: Quickshell.env("HOME") + "/Downloads"
                placeholderText: "Destination folder"
            }
            CheckToggle {
                id: playlist
                text: "Download playlist"
                palette.windowText: Style.foreground
            }
            PillButton {
                width: parent.width
                text: "Download"
                enabled: url.text.trim() !== "" && !Tasks.download.running
                onClicked: Tasks.download.start(["download", format.currentText.toLowerCase(), url.text, directory.text, playlist.checked ? "true" : "false"])
            }
            TaskStatus {
                width: parent.width
                task: Tasks.download
            }
        }
    }
    Component {
        id: media
        Column {
            spacing: 10
            BodyText {
                width: parent.width
                text: "Drop a file below or enter its full path. Output is saved beside the original."
                color: Style.muted
            }
            FileField {
                id: file
                width: parent.width
            }
            Choice {
                id: operation
                width: parent.width
                model: ["Extract MP3", "Mute Video", "Rotate", "Mirror", "Resize", "Trim", "Switcheroo"]
            }
            Field {
                id: parameter
                width: parent.width
                visible: operation.currentIndex === 4 || operation.currentIndex === 5
                placeholderText: operation.currentIndex === 4 ? "Width, e.g. 1280" : "Start duration: 00:01:00 00:00:30"
            }
            PillButton {
                width: parent.width
                text: "Run"
                enabled: (operation.currentIndex === 6 || file.path !== "") && !Tasks.media.running
                onClicked: {
                    if (operation.currentIndex === 6)
                        Quickshell.execDetached(["switcheroo"]);
                    else
                        Tasks.media.start(["media", ["mp3", "silent", "rotate", "mirror", "resize", "trim"][operation.currentIndex], file.path, parameter.text]);
                }
            }
            TaskStatus {
                width: parent.width
                task: Tasks.media
            }
            BodyText {
                width: parent.width
                text: Tasks.media.result.text || ""
                font.pixelSize: 12
            }
        }
    }
    Component {
        id: ip
        Column {
            spacing: 10
            Field {
                id: address
                width: parent.width
                placeholderText: "IP address (blank = your public IP)"
                onAccepted: Tasks.ip.start(["ip", text])
            }
            PillButton {
                width: parent.width
                text: "Look Up"
                enabled: !Tasks.ip.running
                onClicked: Tasks.ip.start(["ip", address.text])
            }
            TaskStatus {
                width: parent.width
                task: Tasks.ip
            }
            BodyText {
                width: parent.width
                text: [Tasks.ip.result.ip, Tasks.ip.result.city, Tasks.ip.result.region, Tasks.ip.result.country, Tasks.ip.result.isp, Tasks.ip.result.timezone].filter(Boolean).join("\n")
            }
            BodyText {
                width: parent.width
                text: "Approximate public-IP location from ipwho.is."
                color: Style.muted
            }
            HistoryList {
                width: parent.width
                kind: "ip"
            }
        }
    }
    Component {
        id: emoji
        EmojiPanel {}
    }
    Component {
        id: exif
        ExifPanel {}
    }
    Component {
        id: periodic
        PeriodicPanel {}
    }
    Component {
        id: settings
        Column {
            spacing: 10
            BodyText {
                width: parent.width
                text: ({
                        apps: "",
                        search: "Search your files and open a result with its default app.",
                        color: "Select a screen pixel; its hex value is copied to the clipboard.",
                        config: "Edit your own Hyprland configuration. No sudo is used.",
                        startup: "Autostart commands are grouped inside hyprland.lua.",
                        update: "Upgrade official packages and installed AUR packages when an AUR helper is present.",
                        clean: "Review cache cleanup and unused packages in a terminal.",
                        account: "Change your password or leave this session to choose another user.",
                        network: "Edit connections, addresses and DNS using NetworkManager.",
                        appearance: "Browse wallpapers.",
                        power: "Lock, log out, suspend or power off.",
                        diagnostics: "Inspect monitors, input devices and graphics logs."
                    })[root.kind] || ""
            }
            Repeater {
                model: ({
                        apps: [["Install", "install-app"], ["Uninstall", "remove-app"]],
                        search: [["Search files", "find-file"], ["Search file contents", "find-text"]],
                        color: [["Pick color", "color"]],
                        config: [["Edit hyprland.lua", "edit-hypr"]],
                        startup: [["Edit startup commands", "edit-hypr"]],
                        update: [["Update system", "update"]],
                        clean: [["Clean system", "clean"]],
                        account: [["Change password", "password"], ["Switch user / log out", "logout"]],
                        network: [["Connections / DNS", "network"], ["Network diagnostics", "network-info"]],
                        appearance: [["Wallpapers", "appearance"]],
                        power: [["Session controls", "power"]],
                        diagnostics: [["System information", "info"], ["Monitors", "monitors"], ["Collect diagnostics", "diagnostics"]]
                    })[root.kind] || []
                delegate: PillButton {
                    required property var modelData
                    width: parent.width
                    text: modelData[0]
                    onClicked: {
                        if (modelData[1] === "appearance")
                            ShellState.setPanel("wallpaper");
                        else if (["power", "logout"].includes(modelData[1]))
                            ShellState.setPanel("power");
                        else if (modelData[1] === "color") {
                            ShellState.close();
                            Quickshell.execDetached(["hyprpicker", "-a"]);
                        } else
                            root.terminal(modelData[1]);
                    }
                }
            }
        }
    }
    Component {
        id: interfaceSettings
        InterfacePanel {}
    }
    Component {
        id: systemSettings
        SystemPanel {}
    }
    Component {
        id: networkSettings
        NetworkPanel {}
    }
    Component {
        id: calculator
        CalculatorPanel {}
    }
    Component {
        id: color
        ColorPanel {}
    }
}
