import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Io
import qs

Scope {
    id: root
    property bool ready: false
    property string previousProfile: ""
    property var bluetoothState: ({})
    property string wifiName: ""
    function notify(title, body) {
        Quickshell.execDetached(["notify-send", "-a", "hshell", "-t", "4000", title, body || ""]);
    }
    Timer {
        interval: 2500
        running: true
        onTriggered: {
            root.previousProfile = Backend.powerProfile;
            root.wifiName = Controls.connectedWifi ? Controls.connectedWifi.name : "";
            root.ready = true;
        }
    }
    Connections {
        target: Controls.sink ? Controls.sink.audio : null
        function onVolumeChanged() {
            if (root.ready)
                ShellState.showOsd("volume");
        }
        function onMutedChanged() {
            if (root.ready)
                ShellState.showOsd("volume");
        }
    }
    Connections {
        target: Backend
        function onBrightnessChanged() {
            if (root.ready)
                ShellState.showOsd("brightness");
        }
        function onPowerProfileChanged() {
            if (root.ready && Backend.powerProfile !== root.previousProfile && Backend.powerProfile !== "unavailable")
                root.notify("Power profile", Backend.powerProfile);
            root.previousProfile = Backend.powerProfile;
        }
    }
    Process {
        command: ["env", "LC_ALL=C", "nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (!root.ready)
                    return;
                const connected = line.match(/^([^:]+): connected to (.+)$/);
                const disconnected = line.match(/^([^:]+): disconnected$/);
                if (connected)
                    root.notify("Network connected", connected[1] + " · " + connected[2]);
                else if (disconnected)
                    root.notify("Network disconnected", disconnected[1]);
            }
        }
    }
    Instantiator {
        model: Controls.bluetoothDevices
        delegate: QtObject {
            required property var modelData
            property bool wasConnected: modelData.connected
            property Connections watcher: Connections {
                target: modelData
                function onConnectedChanged() {
                    if (root.ready && modelData.connected !== wasConnected)
                        root.notify(modelData.connected ? "Bluetooth connected" : "Bluetooth disconnected", modelData.name || modelData.deviceName);
                    wasConnected = modelData.connected;
                }
            }
        }
    }
    Process {
        command: ["python3", ShellState.scripts + "usb-monitor.py"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const event = JSON.parse(line);
                    root.notify(event.summary, event.body);
                } catch (e) {}
            }
        }
    }
    Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("change"))
                    Backend.refreshStatus();
            }
        }
    }
}
