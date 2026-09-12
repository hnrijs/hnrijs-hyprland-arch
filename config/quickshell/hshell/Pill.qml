import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components

Scope {
    id: root
    required property var screen
    readonly property bool expanded: ShellState.expanded && ShellState.activeScreen === screen.name
    PanelWindow {
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 58
        exclusiveZone: 58
        color: "transparent"
        mask: Region {}
        WlrLayershell.namespace: "hshell-space"
    }
    PanelWindow {
        id: window
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: root.expanded || grow.running ? root.screen.height : 110
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "hshell"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        HyprlandFocusGrab {
            active: root.expanded
            windows: [window]
            onCleared: ShellState.close()
        }
        mask: Region {
            item: card
            radius: 26
        }
        Rectangle {
            id: card
            x: (parent.width - width) / 2
            y: 8
            width: root.expanded ? Math.min(root.screen.width - 24, (ShellState.panel === "overview" || (ShellState.panel === "tool" && ShellState.toolName === "periodic")) ? 1040 : 620) : compact.desiredWidth
            height: root.expanded ? Math.min(root.screen.height - 24, Math.max(150, panelLoader.item ? panelLoader.item.implicitHeight : 150)) : compact.desiredHeight
            radius: 26
            color: Style.bg0
            clip: true
            border.color: Style.bg3
            border.width: root.expanded ? 1 : 0
            Behavior on width {
                NumberAnimation {
                    duration: 230
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    id: grow
                    duration: 230
                    easing.type: Easing.OutCubic
                }
            }
            CompactPill {
                id: compact
                width: parent.width
                visible: !root.expanded
                screenName: root.screen.name
            }
            Loader {
                id: panelLoader
                anchors.fill: parent
                active: root.expanded
                visible: root.expanded
                sourceComponent: Component {
                    PanelContent {
                        shellWindow: window
                    }
                }
            }
            Keys.onEscapePressed: ShellState.back()
        }
    }
}
