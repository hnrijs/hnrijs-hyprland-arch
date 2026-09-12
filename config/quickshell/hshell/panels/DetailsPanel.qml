import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import qs
import qs.components

Column {
    id: root
    required property string kind
    required property var shellWindow
    spacing: 10
    Loader {
        width: parent.width
        height: item ? item.implicitHeight : 0
        sourceComponent: root.kind === "wifi" ? wifi : root.kind === "bluetooth" ? bluetooth : root.kind === "nightlight" ? night : root.kind === "tray" ? tray : audio
    }
    Component {
        id: wifi
        Column {
            spacing: 10
            PillButton {
                width: parent.width
                text: Controls.wifiOn ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                onClicked: Controls.wifi()
            }
            BodyText {
                width: parent.width
                visible: !Controls.wifiDevice
                text: "No Wi-Fi adapter found"
            }
            BodyText {
                width: parent.width
                text: Controls.wifiError
                visible: text !== ""
            }
            Column {
                width: parent.width
                spacing: 6
                visible: !!Controls.pendingWifiNetwork
                BodyText {
                    width: parent.width
                    text: Controls.pendingWifiNetwork ? "Password for " + Controls.pendingWifiNetwork.name : ""
                }
                Field {
                    id: password
                    width: parent.width
                    echoMode: TextInput.Password
                    placeholderText: "Wi-Fi password"
                    onAccepted: {
                        Controls.connectWifi(text);
                        clear();
                    }
                }
                PillButton {
                    width: parent.width
                    text: "Connect"
                    onClicked: {
                        Controls.connectWifi(password.text);
                        password.clear();
                    }
                }
            }
            Repeater {
                model: ["Saved networks", "Available networks"]
                delegate: Column {
                    id: group
                    required property string modelData
                    width: parent.width
                    spacing: 8
                    BodyText {
                        text: group.modelData
                        color: Style.muted
                    }
                    Repeater {
                        model: group.modelData === "Saved networks" ? Controls.knownWifiNetworks : Controls.availableWifiNetworks
                        delegate: Column {
                            required property var modelData
                            width: parent.width
                            spacing: 3
                            PillButton {
                                width: parent.width
                                text: modelData.name || "Hidden network"
                                detail: (modelData.connected ? "Connected · " : modelData.known ? "Saved · " : "") + Math.round(modelData.signalStrength * 100) + "%"
                                selected: modelData.connected
                                enabled: !modelData.stateChanging
                                onClicked: Controls.selectWifi(modelData)
                            }
                            PillButton {
                                visible: modelData.known
                                width: parent.width
                                text: "Forget network"
                                onClicked: modelData.forget()
                            }
                        }
                    }
                }
            }
            PillButton {
                width: parent.width
                text: "Advanced / enterprise settings"
                onClicked: Quickshell.execDetached(["alacritty", "-e", "nmtui"])
            }
        }
    }
    Component {
        id: bluetooth
        Column {
            spacing: 10
            PillButton {
                width: parent.width
                text: Controls.adapter && Controls.adapter.enabled ? "Turn Bluetooth off" : "Turn Bluetooth on"
                onClicked: Controls.bluetooth()
            }
            BodyText {
                width: parent.width
                text: Controls.adapter ? "Scanning while this panel is open" : "No Bluetooth adapter"
                color: Style.muted
            }
            Repeater {
                model: Controls.bluetoothDevices
                delegate: Column {
                    required property var modelData
                    width: parent.width
                    spacing: 6
                    PillButton {
                        width: parent.width
                        text: modelData.name || modelData.deviceName
                        detail: modelData.connected ? "Connected · disconnect" : modelData.paired ? "Paired · connect" : "Pair device"
                        selected: modelData.connected
                        onClicked: Controls.connectBluetooth(modelData)
                    }
                    Row {
                        width: parent.width
                        spacing: 6
                        visible: modelData.paired || modelData.bonded
                        PillButton {
                            width: (parent.width - 6) / 2
                            text: modelData.trusted ? "Trusted ✓" : "Trust device"
                            selected: modelData.trusted
                            onClicked: modelData.trusted = !modelData.trusted
                        }
                        PillButton {
                            width: (parent.width - 6) / 2
                            text: "Forget"
                            onClicked: modelData.forget()
                        }
                    }
                }
            }
            PillButton {
                width: parent.width
                text: "Pairing with PIN / advanced"
                onClicked: Quickshell.execDetached(["alacritty", "-e", "bluetoothctl"])
            }
            BodyText {
                width: parent.width
                text: "For PIN pairing: agent on, default-agent, then pair the device address."
                color: Style.muted
            }
        }
    }
    Component {
        id: audio
        Column {
            spacing: 10
            PillButton {
                width: parent.width
                text: "Toggle mute"
                onClicked: root.kind === "microphone" ? Controls.mic() : Controls.mute()
            }
            Repeater {
                model: root.kind === "microphone" ? Controls.audioSources : Controls.audioSinks
                delegate: PillButton {
                    required property var modelData
                    width: parent.width
                    text: modelData.description || modelData.name
                    selected: root.kind === "microphone" ? modelData === Controls.source : modelData === Controls.sink
                    onClicked: {
                        if (root.kind === "microphone")
                            Pipewire.preferredDefaultAudioSource = modelData;
                        else
                            Pipewire.preferredDefaultAudioSink = modelData;
                    }
                }
            }
            PillSlider {
                width: parent.width
                visible: root.kind === "microphone"
                caption: "Microphone level"
                value: Controls.source ? Controls.source.audio.volume : 0
                onMoved: if (Controls.source)
                    Controls.source.audio.volume = value
            }
        }
    }
    Component {
        id: night
        Column {
            spacing: 10
            PillButton {
                width: parent.width
                text: "Toggle night light"
                onClicked: Backend.toggleNightLight()
            }
            PillSlider {
                width: parent.width
                from: 2500
                to: 6000
                stepSize: 50
                value: ShellState.nightLightTemperature
                icon: "󰖔"
                caption: "Temperature"
                displayValue: Math.round(value) + " K"
                onMoved: Backend.setNightLightTemperature(value)
            }
        }
    }
    Component {
        id: tray
        Column {
            spacing: 10
            BodyText {
                width: parent.width
                text: "Click to activate. Hold for the app menu, including Quit when provided."
                color: Style.muted
            }
            Repeater {
                model: SystemTray.items
                delegate: PillButton {
                    required property var modelData
                    width: parent.width
                    text: modelData.title || modelData.tooltipTitle || modelData.id
                    onClicked: modelData.onlyMenu ? modelData.display(root.shellWindow, 0, 60) : modelData.activate()
                    onPressAndHold: modelData.display(root.shellWindow, 0, 60)
                }
            }
        }
    }
}
