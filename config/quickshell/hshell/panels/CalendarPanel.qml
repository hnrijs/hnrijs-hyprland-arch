import QtQuick
import QtQuick.Controls
import qs
import qs.components

Column {
    id: root
    property date month: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property date today: new Date()
    spacing: 12
    Component.onCompleted: if (Preferences.weather)
        Tasks.weather.start(["weather", Preferences.city])
    Row {
        width: parent.width
        PillButton {
            width: 60
            text: "‹"
            onClicked: root.month = new Date(root.month.getFullYear(), root.month.getMonth() - 1, 1)
        }
        BodyText {
            width: parent.width - 120
            height: 44
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(root.month, "MMMM yyyy")
            font.pixelSize: 20
        }
        PillButton {
            width: 60
            text: "›"
            onClicked: root.month = new Date(root.month.getFullYear(), root.month.getMonth() + 1, 1)
        }
    }
    Grid {
        width: parent.width
        columns: 7
        spacing: 4
        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
            delegate: BodyText {
                required property string modelData
                width: (parent.width - 24) / 7
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Style.muted
            }
        }
        Repeater {
            model: 42
            delegate: Rectangle {
                required property int index
                readonly property int day: index - ((root.month.getDay() + 6) % 7) + 1
                readonly property bool valid: day > 0 && day <= new Date(root.month.getFullYear(), root.month.getMonth() + 1, 0).getDate()
                readonly property bool isToday: valid && day === root.today.getDate() && root.month.getMonth() === root.today.getMonth() && root.month.getFullYear() === root.today.getFullYear()
                width: (parent.width - 24) / 7
                height: 42
                radius: 21
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 36
                    height: 36
                    radius: 18
                    color: parent.isToday ? Style.foreground : "transparent"
                }
                BodyText {
                    anchors.centerIn: parent
                    text: new Date(root.month.getFullYear(), root.month.getMonth(), parent.day).getDate()
                    color: parent.isToday ? Style.bg0 : parent.valid ? Style.foreground : Style.bg3
                }
            }
        }
    }
    Rectangle {
        width: parent.width
        height: 1
        color: Style.bg3
    }
    Column {
        width: parent.width
        spacing: 8
        visible: Preferences.weather
        BodyText {
            width: parent.width
            text: Tasks.weather.result.temperature !== undefined ? Tasks.weather.result.city + "  ·  " + Tasks.weather.result.temperature + " °C" : Preferences.city
            font.pixelSize: 24
        }
        BodyText {
            width: parent.width
            text: Tasks.weather.result.description || ""
            color: Style.muted
        }
        BodyText {
            width: parent.width
            text: Tasks.weather.result.feels !== undefined ? "Feels " + Tasks.weather.result.feels + " °C  ·  Wind " + Tasks.weather.result.wind + " km/h" : ""
            color: Style.muted
            font.pixelSize: 12
        }
        TaskStatus {
            width: parent.width
            task: Tasks.weather
        }
    }
}
