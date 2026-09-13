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
    readonly property var monitor: Hyprland.monitors.values.find(m => m.name === root.screen.name) || null
    readonly property bool fullscreen: Preferences.hideFullscreen && monitor && monitor.activeWorkspace && monitor.activeWorkspace.hasFullscreen
    PanelWindow {
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 58
        exclusiveZone: root.fullscreen ? 0 : 58
        visible: !root.fullscreen
        color: "transparent"
        mask: Region {}
        WlrLayershell.namespace: "hshell-space"
    }
    PanelWindow {
        id: window
        visible: root.expanded || !root.fullscreen
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: root.screen.height
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
            width: root.expanded ? Math.min(root.screen.width - 24, (ShellState.panel === "tool" && ShellState.toolName === "periodic") ? 1040 : ShellState.panel === "calendar" ? 420 : 620) : compact.desiredWidth
            height: root.expanded ? Math.min(root.screen.height - 24, Math.max(70, panelLoader.item ? panelLoader.item.implicitHeight : 70)) : compact.desiredHeight
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
            Keys.onEscapePressed: ShellState.escape()
        }
    }
}
