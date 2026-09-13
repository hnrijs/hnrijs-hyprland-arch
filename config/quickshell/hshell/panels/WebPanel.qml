import QtQuick
import Quickshell
import qs
import qs.components

Column {
    id: root
    spacing: 12
    property string site: ""
    property string searchUrl: ""
    function open(url) {
        Quickshell.execDetached(["xdg-open", url]);
        ShellState.close();
    }
    function search(name, url) {
        site = name;
        searchUrl = url;
        query.clear();
        query.forceActiveFocus();
    }
    Field {
        id: query
        width: parent.width
        visible: root.site !== ""
        placeholderText: "Search " + root.site + "…"
        onAccepted: if (text.trim())
            root.open(root.searchUrl + encodeURIComponent(text.trim()))
    }
    Flow {
        width: parent.width
        spacing: 8
        Repeater {
            model: [["ChatGPT", "https://chatgpt.com/"], ["Gemini", "https://gemini.google.com/"], ["Claude", "https://claude.ai/"], ["OpenCode", "https://opencode.ai/"], ["YouTube", "https://www.youtube.com/results?search_query=", true], ["GitHub", "https://github.com/search?q=", true], ["Reddit", "https://www.reddit.com/search/?q=", true], ["Windy", "https://www.windy.com/"], ["Arch Wiki", "https://wiki.archlinux.org/"], ["Quickshell Wiki", "https://quickshell.org/docs/"], ["Hyprland Wiki", "https://wiki.hypr.land/"]]
            delegate: PillButton {
                required property var modelData
                width: (parent.width - 8) / 2
                text: modelData[0]
                selected: root.site === modelData[0]
                onClicked: modelData[2] ? root.search(modelData[0], modelData[1]) : root.open(modelData[1])
            }
        }
    }
}
