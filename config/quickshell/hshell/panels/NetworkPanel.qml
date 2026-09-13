import QtQuick
import qs
import qs.components

Column {
    id: root
    spacing: 12
    property int selected: 0
    readonly property var network: Tasks.network
    Component.onCompleted: network.start(["network-settings", "status"])
    BodyText {
        text: "Connection"
    }
    Repeater {
        model: network.result.connections || []
        delegate: PillButton {
            required property var modelData
            required property int index
            width: parent.width
            text: modelData.name
            selected: root.selected === index
            onClicked: root.selected = index
        }
    }
    BodyText {
        visible: !(network.result.connections || []).length
        text: "Connect to Wi-Fi or Ethernet to Configure DNS"
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: [["dhcp", "󰈀", "Automatic"], ["cloudflare", "󰅟", "Cloudflare"], ["google", "󰊭", "Google DNS"]]
            delegate: ControlTile {
                required property var modelData
                property var connection: (network.result.connections || [])[root.selected] || null
                width: (parent.width - 16) / 3
                symbol: modelData[1]
                iconSource: modelData[0] === "dhcp" ? "" : Qt.resolvedUrl("../assets/dns-" + modelData[0] + (selected && Style.activeText.r < 0.5 ? "-dark" : "-light") + ".svg")
                text: modelData[2]
                detail: modelData[0] === "dhcp" ? "From Router" : modelData[0] === "google" ? "8.8.8.8" : "1.1.1.1"
                selected: !!connection && connection.preset === modelData[0]
                enabled: !!connection && !network.running
                onClicked: network.start(["network-settings", "dns", connection.uuid, modelData[0]])
            }
        }
    }
    ControlTile {
        width: parent.width
        symbol: "󰒃"
        text: "Firewall"
        selected: !!network.result.firewall
        detail: selected ? "UFW Enabled" : "UFW Disabled"
        enabled: !network.running
        onClicked: network.start(["network-settings", "firewall", selected ? "off" : "on"])
    }
    TaskStatus {
        width: parent.width
        task: network
        showCancel: false
    }
    PillButton {
        text: "Refresh"
        enabled: !network.running
        onClicked: network.start(["network-settings", "status"])
    }
}
