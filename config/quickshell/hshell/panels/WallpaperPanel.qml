import QtQuick
import QtQuick.Controls
import qs
import qs.components

Column {
    spacing: 12
    Component.onCompleted: WallpaperState.refreshWallpapers()
    BodyText {
        text: "Wallpaper & shell theme"
        font.pixelSize: 22
    }
    Flow {
        width: parent.width
        spacing: 6
        Repeater {
            model: [["mocha", "Mocha Blue"], ["monochrome", "Monochrome"], ["tokyo", "Tokyo Night"], ["gruvbox", "Gruvbox"], ["nord", "Nord"]]
            delegate: PillButton {
                required property var modelData
                width: 160
                text: modelData[1]
                selected: Preferences.theme === modelData[0]
                onClicked: Preferences.save("theme", modelData[0])
            }
        }
    }
    CheckToggle {
        text: "Also change the LightDM login wallpaper"
        checked: Preferences.syncLogin
        palette.windowText: Style.foreground
        onToggled: Preferences.save("syncLogin", checked ? "true" : "false")
    }
    BodyText {
        width: parent.width
        text: "~/Pictures/Wallpapers · Login wallpaper is shared by all users; authentication may be requested."
        color: Style.muted
    }
    Row {
        spacing: 8
        PillButton {
            text: "Open folder"
            onClicked: WallpaperState.openWallpaperFolder()
        }
        PillButton {
            text: "Refresh"
            onClicked: WallpaperState.refreshWallpapers()
        }
    }
    BodyText {
        width: parent.width
        text: WallpaperState.busy ? "Applying wallpaper…" : WallpaperState.error
        visible: text !== ""
    }
    Flow {
        width: parent.width
        spacing: 10
        Repeater {
            model: WallpaperState.wallpapers
            delegate: Rectangle {
                required property var modelData
                width: (parent.width - 20) / 3
                height: 160
                radius: 20
                color: Style.bg1
                clip: true
                Image {
                    width: parent.width
                    height: 120
                    source: modelData.url
                    sourceSize: Qt.size(320, 240)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
                BodyText {
                    x: 10
                    y: 127
                    width: parent.width - 20
                    text: modelData.name
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: !WallpaperState.busy
                    onClicked: WallpaperState.setWallpaper(modelData.path)
                }
            }
        }
    }
    BodyText {
        width: parent.width
        visible: WallpaperState.wallpapers.length === 0
        text: "Add images to Pictures/Wallpapers, then press Refresh."
    }
}
