import QtQuick
import Quickshell
import qs
import qs.components

Column {
    id: root
    spacing: 10
    function open(url) {
        Quickshell.execDetached(["xdg-open", url]);
        ShellState.close();
    }
    Field {
        id: query
        width: parent.width
        placeholderText: "Search the web…"
        onAccepted: root.open("https://duckduckgo.com/?q=" + encodeURIComponent(text))
    }
    Row {
        width: parent.width
        spacing: 8
        PillButton {
            width: (parent.width - 8) / 2
            text: "DuckDuckGo"
            onClicked: root.open("https://duckduckgo.com/?q=" + encodeURIComponent(query.text))
        }
        PillButton {
            width: (parent.width - 8) / 2
            text: "Google"
            onClicked: root.open("https://www.google.com/search?q=" + encodeURIComponent(query.text))
        }
    }
    BodyText {
        text: "AI"
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: [["ChatGPT", "https://chatgpt.com/"], ["Claude", "https://claude.ai/"], ["Gemini", "https://gemini.google.com/"], ["Perplexity", "https://www.perplexity.ai/"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 8) / 2
                text: modelData[0]
                onClicked: root.open(modelData[1])
            }
        }
    }
    BodyText {
        text: "Documentation"
    }
    Repeater {
        model: [["Arch Wiki", "https://wiki.archlinux.org/"], ["Quickshell Wiki", "https://quickshell.org/docs/"], ["Hyprland Wiki", "https://wiki.hypr.land/"]]
        delegate: PillButton {
            required property var modelData
            width: parent.width
            text: "󰖟  " + modelData[0]
            onClicked: root.open(modelData[1])
        }
    }
}
