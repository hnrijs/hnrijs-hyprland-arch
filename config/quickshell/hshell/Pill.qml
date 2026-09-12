import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.components
import qs.panels

Scope {
    id: root
    required property var screen
    readonly property bool expanded: ShellState.expanded && ShellState.activeScreen === screen.name
    readonly property bool wide: screen.width >= 1280
    readonly property string detail: ShellState.leftPanel || ShellState.rightPanel
    readonly property bool inlineDetail: expanded && !wide && detail !== ""
    readonly property real mainWidth: expanded ? Math.min(screen.width - 24, ShellState.panel === "overview" ? 1040 : 620) : ShellState.osd !== "" ? 340 : headerHover.hovered ? Math.min(620, screen.width - 24) : ShellState.workspaceNotice ? 250 : 160
    PanelWindow {
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 60
        exclusiveZone: 60
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
        implicitHeight: root.expanded ? Math.max(card.y + card.height + 8, leftCard.visible ? leftCard.y + leftCard.height + 8 : 0, rightCard.visible ? rightCard.y + rightCard.height + 8 : 0) : 60
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
            Region {
                x: card.x
                y: card.y
                width: card.width
                height: card.height
                radius: 28
            }
            Region {
                x: leftCard.x
                y: leftCard.y
                width: leftCard.visible ? leftCard.width : 0
                height: leftCard.visible ? leftCard.height : 0
                radius: 28
            }
            Region {
                x: rightCard.x
                y: rightCard.y
                width: rightCard.visible ? rightCard.width : 0
                height: rightCard.visible ? rightCard.height : 0
                radius: 28
            }
        }
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }
        Rectangle {
            id: card
            x: (parent.width - width) / 2
            y: 8
            width: root.mainWidth
            height: root.expanded ? Math.min(root.screen.height - 24, 72 + body.implicitHeight + 20) : 44
            radius: 28
            color: Style.bg0
            border.width: root.expanded ? 1 : 0
            border.color: Style.bg3
            FocusScope {
                anchors.fill: parent
                Keys.onEscapePressed: {
                    if (root.inlineDetail || ShellState.leftPanel || ShellState.rightPanel) {
                        ShellState.leftPanel = "";
                        ShellState.rightPanel = "";
                    } else
                        ShellState.close();
                }
                Item {
                    id: header
                    x: 12
                    width: parent.width - 24
                    height: root.expanded ? 60 : 44
                    HoverHandler {
                        id: headerHover
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (ShellState.panel === "auth")
                                return;
                            const next = mouse.button === Qt.RightButton ? "menu" : mouse.button === Qt.MiddleButton ? "calendar" : "control";
                            if (root.expanded && ShellState.panel === next)
                                ShellState.close();
                            else
                                ShellState.showOnScreen(next, root.screen.name);
                        }
                    }
                    BodyText {
                        anchors.centerIn: parent
                        visible: root.expanded || ShellState.osd === ""
                        text: Qt.formatDateTime(clock.date, "HH:mm") + (!root.expanded && ShellState.workspaceNotice && Hyprland.focusedWorkspace ? " · WS " + Hyprland.focusedWorkspace.id : "")
                        font.pixelSize: 20
                        font.bold: true
                    }
                    BodyText {
                        visible: !root.expanded && headerHover.hovered && ShellState.osd === "" && !ShellState.workspaceNotice
                        width: Math.max(0, parent.width / 2 - 85)
                        anchors.verticalCenter: parent.verticalCenter
                        x: 8
                        text: Controls.player ? (Controls.player.trackTitle || Controls.player.identity) : Qt.formatDateTime(clock.date, "ddd, d MMM")
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Style.muted
                    }
                    Row {
                        visible: !root.expanded && headerHover.hovered && ShellState.osd === "" && !ShellState.workspaceNotice
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 4
                        PillButton {
                            width: 42
                            text: "󰕾"
                            onHoveredChanged: if (hovered)
                                ShellState.showOsd("volume")
                            onClicked: Controls.mute()
                        }
                        PillButton {
                            width: 42
                            text: "󰃠"
                            onHoveredChanged: if (hovered)
                                ShellState.showOsd("brightness")
                        }
                        PillButton {
                            width: 70
                            text: Controls.hasBattery ? Math.round(Controls.batteryLevel * 100) + "%" : "󰤨"
                            onClicked: {
                                ShellState.showOnScreen("control", root.screen.name);
                                ShellState.side("wifi", "left");
                            }
                        }
                    }
                    PillSlider {
                        anchors.fill: parent
                        visible: !root.expanded && ShellState.osd !== ""
                        icon: ShellState.osd === "volume" ? "󰕾" : "󰃠"
                        caption: ShellState.osd === "volume" ? "Volume" : "Brightness"
                        enabled: ShellState.osd === "volume" ? !!Controls.sink : Backend.brightnessAvailable
                        value: ShellState.osd === "volume" ? (Controls.sink ? Controls.sink.audio.volume : 0) : Backend.brightness / 100
                        displayValue: ShellState.osd === "brightness" && !Backend.brightnessAvailable ? "Unavailable" : Math.round(value * 100) + "%"
                        onMoved: {
                            if (ShellState.osd === "volume")
                                Controls.volume(value);
                            else
                                Backend.setBrightness(value * 100);
                            ShellState.showOsd(ShellState.osd);
                        }
                    }
                    PillButton {
                        visible: root.expanded && ShellState.panel !== "auth"
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        width: 48
                        text: "‹"
                        onClicked: {
                            if (root.detail !== "") {
                                ShellState.leftPanel = "";
                                ShellState.rightPanel = "";
                            } else
                                ShellState.close();
                        }
                    }
                    PillButton {
                        visible: root.expanded && ShellState.panel !== "auth"
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        width: 48
                        text: "󰀻"
                        onClicked: ShellState.setPanel("menu")
                    }
                }
                ScrollView {
                    id: scroll
                    x: 18
                    y: 64
                    width: parent.width - 36
                    height: parent.height - y - 16
                    visible: root.expanded
                    clip: true
                    contentWidth: availableWidth
                    Loader {
                        id: body
                        width: scroll.availableWidth
                        active: root.expanded
                        sourceComponent: root.inlineDetail ? inlinePanel : ({
                                control: control,
                                launcher: launcher,
                                clipboard: clipboard,
                                calendar: calendar,
                                wallpaper: wallpaper,
                                power: power,
                                menu: menu,
                                overview: overview,
                                auth: auth
                            })[ShellState.panel] || null
                        onLoaded: {
                            if (item.takeInitialFocus)
                                Qt.callLater(() => {
                                    if (item)
                                        item.takeInitialFocus();
                                });
                        }
                    }
                }
            }
        }
        Rectangle {
            id: leftCard
            visible: root.expanded && root.wide && ShellState.leftPanel !== ""
            x: card.x - width - 12
            y: card.y
            width: Math.min(340, card.x - 24)
            height: Math.min(root.screen.height - 24, leftLoader.implicitHeight + 32)
            radius: 28
            color: Style.bg0
            border.width: 1
            border.color: Style.bg3
            ScrollView {
                id: leftScroll
                anchors.fill: parent
                anchors.margins: 16
                clip: true
                contentWidth: availableWidth
                Loader {
                    id: leftLoader
                    width: leftScroll.availableWidth
                    active: leftCard.visible
                    sourceComponent: leftPanel
                }
            }
        }
        Rectangle {
            id: rightCard
            visible: root.expanded && root.wide && ShellState.rightPanel !== ""
            x: card.x + card.width + 12
            y: card.y
            width: Math.min(340, card.x - 24)
            height: Math.min(root.screen.height - 24, rightLoader.implicitHeight + 32)
            radius: 28
            color: Style.bg0
            border.width: 1
            border.color: Style.bg3
            ScrollView {
                id: rightScroll
                anchors.fill: parent
                anchors.margins: 16
                clip: true
                contentWidth: availableWidth
                Loader {
                    id: rightLoader
                    width: rightScroll.availableWidth
                    active: rightCard.visible
                    sourceComponent: rightPanel
                }
            }
        }
        Component {
            id: control
            ControlPanel {
                shellWindow: window
            }
        }
        Component {
            id: launcher
            LauncherPanel {}
        }
        Component {
            id: clipboard
            Column {
                spacing: 10
                function takeInitialFocus() {
                    clips.takeInitialFocus();
                }
                PillButton {
                    text: "Clear clipboard history"
                    width: parent.width
                    onClicked: Tasks.clipboard.start(["clipboard-clear"])
                }
                ClipboardPanel {
                    id: clips
                    width: parent.width
                    height: implicitHeight
                }
            }
        }
        Component {
            id: calendar
            CalendarPanel {}
        }
        Component {
            id: wallpaper
            WallpaperPanel {}
        }
        Component {
            id: power
            PowerPanel {}
        }
        Component {
            id: menu
            MenuPanel {}
        }
        Component {
            id: overview
            OverviewPanel {}
        }
        Component {
            id: auth
            AuthPanel {}
        }
        Component {
            id: leftPanel
            SidePanel {
                kind: ShellState.leftPanel
                shellWindow: window
            }
        }
        Component {
            id: rightPanel
            SidePanel {
                kind: ShellState.rightPanel
                shellWindow: window
            }
        }
        Component {
            id: inlinePanel
            SidePanel {
                kind: root.detail
                shellWindow: window
            }
        }
    }
}
