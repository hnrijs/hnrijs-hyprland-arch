import QtQuick
import QtQuick.Controls
import qs
import qs.components

Column {
    spacing: 12
    Component.onCompleted: WallpaperState.refreshWallpapers()
    ListView {
        id: gallery
        width: parent.width
        height: 210
        orientation: ListView.Horizontal
        spacing: 12
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
        model: WallpaperState.wallpapers
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        WheelHandler {
            onWheel: event => {
                gallery.contentX = Math.max(0, Math.min(gallery.contentWidth - gallery.width, gallery.contentX - (event.angleDelta.y || event.angleDelta.x)));
                event.accepted = true;
            }
        }
        delegate: Item {
            required property var modelData
            width: 300
            height: 194
            Image {
                anchors.fill: parent
                source: modelData.url
                sourceSize: Qt.size(600, 388)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: !WallpaperState.busy
                onClicked: WallpaperState.setWallpaper(modelData.path)
            }
        }
    }
    Row {
        width: parent.width
        spacing: 8
        PillButton {
            width: 44
            text: "‹"
            onClicked: gallery.decrementCurrentIndex()
        }
        PillButton {
            width: parent.width - 104
            text: "󰉋"
            Accessible.name: "Open wallpaper folder"
            onClicked: WallpaperState.openWallpaperFolder()
        }
        PillButton {
            width: 44
            text: "›"
            onClicked: gallery.incrementCurrentIndex()
        }
    }
    BodyText {
        width: parent.width
        visible: WallpaperState.busy || WallpaperState.error !== "" || WallpaperState.wallpapers.length === 0
        text: WallpaperState.busy ? "Applying…" : WallpaperState.error || "Add images to ~/Pictures/Wallpapers"
    }
}
