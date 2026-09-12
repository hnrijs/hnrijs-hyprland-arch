import QtQuick
import QtQuick.Controls
import qs
import qs.components

Column {
    id: root
    property date month: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property date today: new Date()
    spacing: 12
    Component.onCompleted: Tasks.weather.start(["weather", Preferences.city])
    Row {
        width: parent.width
        PillButton {
            width: 60
            text: "‹"
            onClicked: root.month = new Date(root.month.getFullYear(), root.month.getMonth() - 1, 1)
        }
        BodyText {
            width: parent.width - 120
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
                color: isToday ? Style.primary : "transparent"
                BodyText {
                    anchors.centerIn: parent
                    text: parent.valid ? parent.day : ""
                    color: parent.isToday ? Style.bg0 : Style.foreground
                }
            }
        }
    }
    Rectangle {
        width: parent.width
        height: 1
        color: Style.bg3
    }
    BodyText {
        text: "Weather"
        font.pixelSize: 20
    }
    Row {
        width: parent.width
        spacing: 8
        Field {
            id: city
            width: parent.width - 108
            text: Preferences.city
            placeholderText: "City"
            onAccepted: {
                Preferences.save("city", text.trim() || "Riga");
                Tasks.weather.start(["weather", Preferences.city]);
            }
        }
        PillButton {
            width: 100
            text: "Search"
            enabled: !Tasks.weather.running
            onClicked: {
                Preferences.save("city", city.text.trim() || "Riga");
                Tasks.weather.start(["weather", Preferences.city]);
            }
        }
    }
    TaskStatus {
        width: parent.width
        task: Tasks.weather
    }
    BodyText {
        width: parent.width
        font.pixelSize: 24
        text: Tasks.weather.result.temperature !== undefined ? Tasks.weather.result.city + " · " + Tasks.weather.result.temperature + " °C" : ""
    }
    BodyText {
        width: parent.width
        text: Tasks.weather.result.description || ""
    }
    BodyText {
        width: parent.width
        text: Tasks.weather.result.feels !== undefined ? "Feels like " + Tasks.weather.result.feels + " °C · Wind " + Tasks.weather.result.wind + " km/h · Humidity " + Tasks.weather.result.humidity + "%" : ""
        color: Style.muted
    }
    BodyText {
        text: "Source: wttr.in"
        color: Style.muted
        font.pixelSize: 12
    }
}
