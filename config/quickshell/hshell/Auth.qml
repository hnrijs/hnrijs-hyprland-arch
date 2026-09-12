pragma Singleton
import QtQuick
import Quickshell
import qs
import Quickshell.Services.Polkit

Singleton {
    id: root
    readonly property var flow: agent.flow
    readonly property bool active: agent.isActive
    readonly property bool registered: agent.isRegistered
    property string previousPanel: "clock"
    PolkitAgent {
        id: agent
        onIsActiveChanged: {
            if (isActive) {
                root.previousPanel = ShellState.panel;
                ShellState.setPanel("auth");
            } else if (ShellState.panel === "auth")
                ShellState.setPanel(root.previousPanel === "auth" ? "clock" : root.previousPanel);
        }
    }
}
