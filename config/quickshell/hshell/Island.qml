import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.panels

PanelWindow {
    id: window
    readonly property bool panelExpanded: ShellState.expanded && screen && ShellState.activeScreen === screen.name

    readonly property int contentPadding: 14
    readonly property int collapsedHeight: 32
    readonly property int cornerWing: 16
    readonly property int canvasWidth: Math.min(552, screen ? screen.width : 552)
    readonly property int canvasHeight: 600
    readonly property int requestedTopPadding: ShellState.panel === "launcher" ? 10 : contentPadding
    readonly property int requestedBottomPadding: ShellState.panel === "launcher" ? 4 : contentPadding
    readonly property int displayedTopPadding: displayedPanel === "launcher" ? 10 : contentPadding
    readonly property int displayedBottomPadding: displayedPanel === "launcher" ? 4 : contentPadding
    readonly property real targetVisualWidth: Math.min(canvasWidth, (window.panelExpanded ? ShellState.targetWidth : 145) + cornerWing * 2)
    readonly property real targetVisualHeight: window.panelExpanded ? panelContentHeight + requestedTopPadding + requestedBottomPadding : collapsedHeight
    readonly property real panelContentHeight: window.panelExpanded ? Math.max(ShellState.panelHeights[ShellState.panel] || 0, requestedPanel ? requestedPanel.implicitHeight : 0) : 0
    property bool contentRevealed: false
    property bool clockRevealed: true
    property string displayedPanel: "control"
    readonly property Item activePanel: {
        const panels = {
            "control": controlPanel,
            "notifications": notificationsPanel,
            "calendar": calendarPanel,
            "emoji": emojiPanel,
            "web": webPanel,
            "tools": toolsPanel,
            "system": systemPanel,
            "launcher": launcherPanel,
            "clipboard": clipboardPanel,
            "notes": quickNotesPanel,
            "wallpaper": wallpaperPanel,
            "power": powerPanel
        };
        return panels[displayedPanel] || null;
    }
    readonly property Item requestedPanel: {
        const panels = {
            "control": controlPanel,
            "notifications": notificationsPanel,
            "calendar": calendarPanel,
            "emoji": emojiPanel,
            "web": webPanel,
            "tools": toolsPanel,
            "system": systemPanel,
            "launcher": launcherPanel,
            "clipboard": clipboardPanel,
            "notes": quickNotesPanel,
            "wallpaper": wallpaperPanel,
            "power": powerPanel
        };
        return panels[ShellState.panel] || null;
    }

    function focusInitialControl() {
        if (!window.panelExpanded || !activePanel)
            return ;

        if (typeof activePanel.takeInitialFocus === "function") {
            activePanel.takeInitialFocus();
            return ;
        }
        activePanel.forceActiveFocus(Qt.TabFocusReason);
        const firstControl = activePanel.nextItemInFocusChain(true);
        if (firstControl && firstControl !== activePanel)
            firstControl.forceActiveFocus(Qt.TabFocusReason);

    }

    function moveFocus(forward) {
        const current = window.activeFocusItem;
        if (!current) {
            focusInitialControl();
            return ;
        }
        const target = current.nextItemInFocusChain(forward);
        if (target)
            target.forceActiveFocus(forward ? Qt.TabFocusReason : Qt.BacktabFocusReason);

    }

    margins.left: Math.round((screen.width - canvasWidth) / 2)
    implicitWidth: canvasWidth
    implicitHeight: canvasHeight
    color: "transparent"
    aboveWindows: true
    focusable: window.panelExpanded
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
    }

    Connections {
        function onPanelChanged() {
            window.contentRevealed = window.panelExpanded;
            if (window.panelExpanded) {
                clockRevealTimer.stop();
                window.clockRevealed = false;
                window.displayedPanel = ShellState.panel;
                focusTimer.restart();
            } else {
                clockRevealTimer.restart();
            }
        }

        function onActiveScreenChanged() { onPanelChanged(); }
        target: ShellState
    }

    FocusScope {
        id: islandSurface

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: window.targetVisualWidth
        height: window.targetVisualHeight
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                ShellState.close();
                event.accepted = true;
                return ;
            }
            if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
                window.moveFocus(true);
                event.accepted = true;
                return ;
            }
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                window.moveFocus(false);
                event.accepted = true;
                return ;
            }
        }

        Rectangle {
            id: islandBody

            x: window.cornerWing
            y: -15
            width: parent.width - window.cornerWing * 2
            height: parent.height + 15
            radius: Style.radius
            color: Style.shellBackground
        }

        Shape {
            x: 0
            width: window.cornerWing
            height: window.cornerWing
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: leftShoulderPath

                readonly property real size: window.cornerWing

                strokeWidth: 0
                fillColor: Style.shellBackground
                startX: 0
                startY: 0

                PathLine {
                    x: leftShoulderPath.size
                    y: 0
                }

                PathLine {
                    x: leftShoulderPath.size
                    y: leftShoulderPath.size
                }

                PathCubic {
                    control1X: leftShoulderPath.size
                    control1Y: leftShoulderPath.size * 0.448
                    control2X: leftShoulderPath.size * 0.552
                    control2Y: 0
                    x: 0
                    y: 0
                }

            }

        }

        Shape {
            x: parent.width - width
            width: window.cornerWing
            height: window.cornerWing
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: rightShoulderPath

                readonly property real size: window.cornerWing

                strokeWidth: 0
                fillColor: Style.shellBackground
                startX: rightShoulderPath.size
                startY: 0

                PathLine {
                    x: 0
                    y: 0
                }

                PathLine {
                    x: 0
                    y: rightShoulderPath.size
                }

                PathCubic {
                    control1X: 0
                    control1Y: rightShoulderPath.size * 0.448
                    control2X: rightShoulderPath.size * 0.448
                    control2Y: 0
                    x: rightShoulderPath.size
                    y: 0
                }

            }

        }

        Row {
            anchors.left: islandBody.left
            anchors.right: islandBody.right
            anchors.top: parent.top
            height: window.collapsedHeight
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            visible: opacity > 0
            opacity: window.clockRevealed ? 1 : 0

            ShellText {
                width: parent.width / 2
                height: parent.height
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                rightPadding: 6
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Style.shellForeground
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            ShellText {
                width: parent.width / 2
                height: parent.height
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 6
                text: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"][clock.date.getDay()] + " " + Qt.formatDateTime(clock.date, "d/M")
                color: Style.shellForeground
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 90
                    easing.type: Easing.OutCubic
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            enabled: !window.panelExpanded
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: mouse => ShellState.showOnScreen(mouse.button === Qt.RightButton ? "system" : mouse.button === Qt.MiddleButton ? "calendar" : "control", window.screen.name)
        }

        Item {
            id: panelHost

            anchors.left: islandBody.left
            anchors.right: islandBody.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: window.contentPadding
            anchors.rightMargin: window.contentPadding
            anchors.topMargin: window.displayedTopPadding
            anchors.bottomMargin: window.displayedBottomPadding
            visible: opacity > 0
            opacity: window.contentRevealed ? 1 : 0
            clip: true

            ControlPanel {
                id: controlPanel

                width: parent.width
                height: parent.height
                visible: window.displayedPanel === "control"
            }

            LauncherPanel {
                id: launcherPanel

                width: parent.width
                visible: window.displayedPanel === "launcher"
            }

            ClipboardPanel {
                id: clipboardPanel

                width: parent.width
                visible: window.displayedPanel === "clipboard"
            }

            QuickNotesPanel {
                id: quickNotesPanel

                width: parent.width
                height: parent.height
                visible: window.displayedPanel === "notes"
            }

            WallpaperPanel {
                id: wallpaperPanel

                width: parent.width
                height: parent.height
                visible: window.displayedPanel === "wallpaper"
            }

            UtilityPanel {
                id: systemPanel
                width: parent.width
                visible: window.displayedPanel === "system"
                category: "system"
            }

            UtilityPanel {
                id: toolsPanel
                width: parent.width
                visible: window.displayedPanel === "tools"
                category: "tools"
            }

            UtilityPanel {
                id: webPanel
                width: parent.width
                visible: window.displayedPanel === "web"
                category: "web"
            }

            UtilityPanel {
                id: emojiPanel
                width: parent.width
                visible: window.displayedPanel === "emoji"
                category: "emoji"
            }

            CalendarPanel {
                id: calendarPanel
                width: parent.width
                visible: window.displayedPanel === "calendar"
            }

            NotificationsPanel {
                id: notificationsPanel
                width: parent.width
                visible: window.displayedPanel === "notifications"
            }

            PowerPanel {
                id: powerPanel

                width: parent.width
                visible: window.displayedPanel === "power"
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Style.animationNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

        Behavior on width {
            NumberAnimation {
                duration: Style.animationNormal
                easing.type: Easing.OutCubic
            }

        }

        Behavior on height {
            enabled: !clipboardPanel.previewTransitionActive

            NumberAnimation {
                duration: Style.animationNormal
                easing.type: Easing.OutCubic
            }

        }

    }

    // Reserve only the collapsed island height, never the expanded canvas.
    PanelWindow {
        screen: window.screen
        anchors { top: true; left: true; right: true }
        implicitHeight: window.collapsedHeight
        exclusiveZone: window.collapsedHeight
        color: "transparent"
        mask: Region {}
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    HyprlandFocusGrab {
        windows: [window]
        active: window.panelExpanded
        onCleared: {
            if (window.panelExpanded)
                ShellState.close();

        }
    }

    Timer {
        id: focusTimer

        interval: 35
        onTriggered: window.focusInitialControl()
    }

    Timer {
        id: clockRevealTimer

        interval: 150
        onTriggered: {
            if (!window.panelExpanded)
                window.clockRevealed = true;

        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: window.panelExpanded
        onActivated: ShellState.close()
    }

    mask: Region {
        item: islandBody
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: Style.radius
        bottomRightRadius: Style.radius
    }

}
