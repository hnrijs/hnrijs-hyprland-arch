import QtQuick
import Quickshell
import qs
import qs.components

Column {
    id: root
    spacing: 12
    property var history: []
    property string submitted: ""
    property var groups: [
        {
            name: "Length",
            units: ["mm", "cm", "dm", "m", "km", "nm", "um", "in", "ft", "yd", "mi"]
        },
        {
            name: "Speed",
            units: ["m/s", "km/h", "mph", "knots"]
        },
        {
            name: "Pressure",
            units: ["psi", "bar", "Pa", "kPa", "MPa", "atm"]
        },
        {
            name: "Power",
            units: ["W", "kW", "MW", "hp"]
        },
        {
            name: "Energy",
            units: ["J", "kJ", "Wh", "kWh", "cal", "kcal"]
        },
        {
            name: "Mass",
            units: ["mg", "g", "kg", "lb", "oz"]
        },
        {
            name: "Temperature",
            units: ["°C", "°F", "K"]
        },
        {
            name: "Volume",
            units: ["ml", "l", "m^3", "gal"]
        },
        {
            name: "Area",
            units: ["mm^2", "cm^2", "m^2", "ha", "km^2", "ft^2"]
        },
        {
            name: "Time",
            units: ["ms", "s", "min", "h", "day"]
        },
        {
            name: "Data",
            units: ["bit", "byte", "kB", "MB", "GB", "TB"]
        },
        {
            name: "Currency",
            units: ["USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "PLN"]
        }
    ]
    function evaluate(value, refresh) {
        if (calc.running)
            return;
        submitted = value;
        calc.start(["calculate", value, refresh ? "refresh" : "cached"]);
    }
    Task {
        id: calc
        onFinished: success => {
            if (success)
                root.history = [
                    {
                        expression: root.submitted,
                        result: result.text
                    }
                ].concat(root.history).slice(0, 30);
        }
    }
    Row {
        width: parent.width
        spacing: 8
        Field {
            id: expression
            width: parent.width - 52
            placeholderText: "(25 + 75) * 3 · 15% of 240 · 10 psi to bar"
            onAccepted: root.evaluate(text, false)
        }
        PillButton {
            width: 44
            text: "="
            enabled: !calc.running
            onClicked: root.evaluate(expression.text, false)
        }
    }
    Rectangle {
        width: parent.width
        height: Math.max(64, answer.implicitHeight + 24)
        radius: 18
        color: Style.bg1
        BodyText {
            id: answer
            x: 12
            y: 12
            width: parent.width - 24
            font.pixelSize: 22
            text: calc.result.text || "0"
        }
        TapHandler {
            onTapped: Quickshell.execDetached(["wl-copy", "--", calc.result.text || "0"])
        }
    }
    BodyText {
        text: "Unit Converter"
    }
    Choice {
        id: category
        width: parent.width
        model: root.groups.map(g => g.name)
        onCurrentIndexChanged: {
            fromUnit.currentIndex = 0;
            toUnit.currentIndex = 1;
        }
    }
    Field {
        id: amount
        width: parent.width
        text: "1"
        placeholderText: "Amount or Expression"
    }
    Row {
        width: parent.width
        spacing: 8
        Choice {
            id: fromUnit
            width: (parent.width - 60) / 2
            model: root.groups[category.currentIndex].units
        }
        PillButton {
            width: 44
            text: "⇄"
            onClicked: {
                const old = fromUnit.currentIndex;
                fromUnit.currentIndex = toUnit.currentIndex;
                toUnit.currentIndex = old;
            }
        }
        Choice {
            id: toUnit
            width: (parent.width - 60) / 2
            model: root.groups[category.currentIndex].units
            currentIndex: 1
        }
    }
    PillButton {
        width: parent.width
        text: "Convert"
        enabled: !calc.running
        onClicked: root.evaluate("(" + amount.text + ") " + fromUnit.currentText + " to " + toUnit.currentText, false)
    }
    Row {
        width: parent.width
        spacing: 8
        visible: category.currentText === "Currency"
        PillButton {
            width: 180
            text: "Refresh Rates"
            enabled: !calc.running
            onClicked: root.evaluate("1 USD to EUR", true)
        }
        BodyText {
            width: parent.width - 188
            text: calc.result.ratesDate || "Cached Rates — Refresh for Recent Rates"
            font.pixelSize: 12
        }
    }
    Flow {
        width: parent.width
        spacing: 6
        Repeater {
            model: ["15% of 240", "sqrt(144)", "sin(30 deg)", "2 kW * 3 h to kWh", "1 in to cm"]
            delegate: PillButton {
                required property string modelData
                width: (parent.width - 6) / 2
                text: modelData
                onClicked: expression.text = modelData
            }
        }
    }
    BodyText {
        width: parent.width
        visible: text !== ""
        text: calc.result.warning || ""
        color: Style.muted
    }
    TaskStatus {
        width: parent.width
        task: calc
    }
    Row {
        width: parent.width
        BodyText {
            width: parent.width - 44
            height: 44
            verticalAlignment: Text.AlignVCenter
            text: "History"
        }
        PillButton {
            width: 44
            text: "󰃢"
            Accessible.name: "Clear Calculator History"
            onClicked: root.history = []
        }
    }
    Repeater {
        model: root.history
        delegate: PillButton {
            required property var modelData
            width: parent.width
            height: 64
            text: modelData.result
            detail: modelData.expression
            onClicked: expression.text = modelData.expression
        }
    }
}
