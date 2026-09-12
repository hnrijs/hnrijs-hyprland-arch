import QtQuick
import QtQuick.Controls
import qs
import qs.components
import qs.panels

Item {
    id: root
    focus: true
    Keys.onEscapePressed: ShellState.back()
    implicitHeight: 106 + content.height
    required property var shellWindow
    property string page: ShellState.panel
    readonly property string title: page === "tool" ? ({
            disks: "Disk space",
            apps: "App manager",
            search: "File search",
            speed: "Speed test",
            emoji: "Emoji",
            color: "Color picker",
            media: "Media tools",
            download: "Downloader",
            ip: "IP locator",
            periodic: "Periodic table",
            config: "Hyprland",
            startup: "Startup",
            defaults: "Default apps",
            account: "Account",
            update: "System update",
            clean: "System clean",
            network: "Network settings",
            diagnostics: "Diagnostics"
        })[ShellState.toolName] || "Tools" : ({
            control: "Control center",
            menu: "Menu",
            tools: "Tools",
            settings: "Settings",
            emoji: "Emoji",
            color: "Colors",
            web: "Quickweb",
            calendar: "Calendar",
            wallpaper: "Wallpaper & theme",
            launcher: "Applications",
            clipboard: "Clipboard",
            power: "Session",
            overview: "Workspaces",
            auth: "Authentication",
            detail: ({wifi:"Wi-Fi",bluetooth:"Bluetooth",audio:"Audio",microphone:"Microphone",nightlight:"Night light",tray:"Tray apps"})[ShellState.detailName]
        })[page] || "hshell"
    Row {
        id: navigation
        x: 20
        y: 14
        width: parent.width - 40
        height: 44
        spacing: 12
        PillButton {
            width: 44
            height: 44
            text: "‹"
            visible: root.page !== "auth"
            onClicked: ShellState.back()
        }
        BodyText {
            width: navigation.width - (root.page === "auth" ? 0 : 112)
            height: 44
            text: root.title
            font.pixelSize: 19
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            elide: Text.ElideRight
        }
        PillButton {
            width: 44
            height: 44
            text: "×"
            visible: root.page !== "auth"
            onClicked: ShellState.close()
        }
    }
    Rectangle {
        x: 20
        y: 70
        width: parent.width - 40
        height: 1
        color: Style.bg3
    }
    Flickable {
        id: viewport
        objectName: "panelViewport"
        x: 20
        y: 86
        width: parent.width - 40
        height: Math.max(0, parent.height - y - 20)
        contentWidth: width
        contentHeight: content.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            visible: size < 1
            width: 6
            contentItem: Rectangle {
                radius: 3
                color: Style.muted
            }
        }
        Loader {
            id: content
            objectName: "pageLoader"
            width: viewport.width - 10
            height: item ? item.implicitHeight : 0
            sourceComponent: ({
                    control: controls,
                    menu: menu,
                    tools: menu,
                    settings: menu,
                    emoji: emoji,
                    color: color,
                    web: web,
                    calendar: calendar,
                    wallpaper: wallpaper,
                    launcher: launcher,
                    clipboard: clipboard,
                    power: power,
                    overview: overview,
                    tool: tool,
                    detail: details,
                    auth: auth
                })[root.page] || null
            onLoaded: {
                viewport.contentY = 0;
                if (["launcher", "clipboard", "auth"].includes(root.page))
                    Qt.callLater(() => {
                        if (item)
                            item.takeInitialFocus();
                    });
                reveal.restart();
            }
            NumberAnimation {
                id: reveal
                target: content
                property: "y"
                from: 10
                to: 0
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }
    Component {
        id: controls
        ControlPanel {
            shellWindow: root.shellWindow
        }
    }
    Component {
        id: menu
        MenuPanel {
            kind: root.page
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
        id: launcher
        LauncherPanel {}
    }
    Component {
        id: power
        PowerPanel {}
    }
    Component {
        id: overview
        OverviewPanel {}
    }
    Component {
        id: emoji
        ToolPanel {
            kind: "emoji"
        }
    }
    Component {
        id: color
        ColorPanel {}
    }
    Component {
        id: web
        WebPanel {}
    }
    Component {
        id: tool
        ToolPanel {
            kind: ShellState.toolName
        }
    }
    Component {
        id: details
        DetailsPanel {
            kind: ShellState.detailName
            shellWindow: root.shellWindow
        }
    }
    Component {
        id: auth
        AuthPanel {}
    }
    Component {
        id: clipboard
        Column {
            spacing: 12
            function takeInitialFocus() {
                clips.takeInitialFocus();
            }
            PillButton {
                width: parent.width
                text: "Clear history"
                onClicked: Tasks.clipboard.start(["clipboard-clear"])
            }
            ClipboardPanel {
                id: clips
                width: parent.width
                height: implicitHeight
            }
        }
    }
}
