import QtQuick
import Quickshell
import qs

Scope {
    id: root
    property bool lowSent: false
    property bool criticalSent: false
    function check() {
        if (!Controls.hasBattery)
            return;
        if (Controls.batteryCharging) {
            lowSent = false;
            criticalSent = false;
            return;
        }
        const percent = Math.round(Controls.batteryLevel * 100);
        if (percent <= 5 && !criticalSent) {
            criticalSent = true;
            lowSent = true;
            Quickshell.execDetached(["notify-send", "-a", "Power", "-u", "critical", "Battery critical", percent + "% remaining"]);
        } else if (percent <= 15 && !lowSent) {
            lowSent = true;
            Quickshell.execDetached(["notify-send", "-a", "Power", "Battery low", percent + "% remaining"]);
        }
    }
    Connections {
        target: Controls
        function onBatteryLevelChanged() {
            root.check();
        }
        function onBatteryChargingChanged() {
            root.check();
        }
    }
    Timer {
        interval: 3000
        running: true
        onTriggered: root.check()
    }
}
