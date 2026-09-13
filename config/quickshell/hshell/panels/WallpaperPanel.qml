import QtQuick
import qs
import qs.components

Item {
    id: root
    implicitHeight: 250
    focus: true
    Component.onCompleted: {
        WallpaperState.refreshWallpapers();
        forceActiveFocus();
    }
    function select(offset) {
        if (!gallery.count || WallpaperState.busy)
            return;
        gallery.currentIndex = (gallery.currentIndex + offset + gallery.count) % gallery.count;
        gallery.positionViewAtIndex(gallery.currentIndex, ListView.Center);
        WallpaperState.setWallpaper(WallpaperState.wallpapers[gallery.currentIndex].path);
    }
    Keys.onLeftPressed: select(-1)
    Keys.onRightPressed: select(1)
    Keys.onReturnPressed: if (gallery.count)
        WallpaperState.setWallpaper(WallpaperState.wallpapers[gallery.currentIndex].path)
    ListView {
        id: gallery
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 12
        clip: true
        model: WallpaperState.wallpapers
        snapMode: ListView.SnapOneItem
        delegate: Image {
            required property var modelData
            required property int index
            width: gallery.width
            height: gallery.height
            source: modelData.url
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gallery.currentIndex = index;
                    WallpaperState.setWallpaper(modelData.path);
                    root.forceActiveFocus();
                }
            }
        }
    }
    BodyText {
        anchors.centerIn: parent
        visible: WallpaperState.error !== "" || gallery.count === 0
        text: WallpaperState.error || "No Images in Wallpaper Folder"
    }
}
