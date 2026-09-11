import QtQuick
import Quickshell
import qs
import qs.components

FocusScope {
    id: root
    property date month: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    readonly property int offset: (new Date(month.getFullYear(), month.getMonth(), 1).getDay() + 6) % 7
    readonly property int days: new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate()
    implicitHeight: 294
    function shift(amount) { month = new Date(month.getFullYear(), month.getMonth() + amount, 1); }
    function takeInitialFocus() { previous.forceActiveFocus(); }
    Column {
        width: parent.width; spacing: 12
        Row {
            width: parent.width; spacing: 8
            IconButton { id: previous; width: 30; height: 30; icon: "‹"; accessibleName: "Previous month"; onClicked: root.shift(-1) }
            ShellText { width: parent.width - 76; height: 30; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; text: Qt.formatDate(root.month, "MMMM yyyy"); font.pixelSize: 16 }
            IconButton { width: 30; height: 30; icon: "›"; accessibleName: "Next month"; onClicked: root.shift(1) }
        }
        Grid {
            width: parent.width; columns: 7; spacing: 3
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                ShellText { required property string modelData; width: (parent.width - 18) / 7; height: 24; text: modelData; horizontalAlignment: Text.AlignHCenter; color: Style.muted }
            }
            Repeater {
                model: 42
                Rectangle {
                    required property int index
                    readonly property int day: index - root.offset + 1
                    readonly property bool valid: day > 0 && day <= root.days
                    readonly property bool today: valid && day === clock.date.getDate() && root.month.getMonth() === clock.date.getMonth() && root.month.getFullYear() === clock.date.getFullYear()
                    width: (parent.width - 18) / 7; height: 30; radius: 7
                    color: today ? Style.foreground : "transparent"
                    ShellText { anchors.centerIn: parent; text: parent.valid ? parent.day : ""; color: parent.today ? Style.bgDim : Style.foreground }
                }
            }
        }
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
}
