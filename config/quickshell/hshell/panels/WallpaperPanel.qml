import QtQuick
import Quickshell.Widgets
import qs
import qs.components

FocusScope {
    id: root

    function takeInitialFocus() {
        if (wallpaperGrid.count > 0 && wallpaperGrid.currentIndex < 0)
            wallpaperGrid.currentIndex = 0;
        wallpaperGrid.forceActiveFocus(Qt.TabFocusReason);
    }

    function moveSelection(offset) {
        if (wallpaperGrid.count === 0)
            return;
        wallpaperGrid.currentIndex = Math.max(0, Math.min(wallpaperGrid.count - 1, Math.max(0, wallpaperGrid.currentIndex) + offset));
        wallpaperGrid.positionViewAtIndex(wallpaperGrid.currentIndex, GridView.Contain);
    }

    Connections {
        target: ShellState
        function onPanelChanged() {
            if (ShellState.panel === "wallpaper")
                WallpaperState.refreshWallpapers();
        }
    }

    Connections {
        target: WallpaperState
        function onWallpapersChanged() {
            wallpaperGrid.currentIndex = WallpaperState.wallpapers.length > 0 ? 0 : -1;
        }
    }

    implicitWidth: 472
    implicitHeight: 382

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width
            height: 30
            ShellText {
                width: parent.width - folderButton.width
                anchors.verticalCenter: parent.verticalCenter
                text: "Wallpapers"
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            FocusScope {
                id: folderButton

                implicitWidth: folderContent.implicitWidth + 16
                width: implicitWidth
                height: 30
                activeFocusOnTab: true
                Keys.onReturnPressed: WallpaperState.openWallpaperFolder()
                Keys.onEnterPressed: WallpaperState.openWallpaperFolder()
                Keys.onSpacePressed: WallpaperState.openWallpaperFolder()
                Accessible.role: Accessible.Button
                Accessible.name: "Open Pictures/Wallpapers"

                Rectangle {
                    anchors.fill: parent
                    radius: Style.radiusSmall
                    color: folderButton.activeFocus || folderPointer.containsMouse ? Style.bg1 : "transparent"
                }

                Row {
                    id: folderContent

                    anchors.centerIn: parent
                    spacing: 6

                    ShellText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰉋"
                        color: Style.primary
                        font.pixelSize: 12
                    }

                    ShellText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Folder"
                        color: Style.primary
                        font.pixelSize: 10
                    }
                }

                MouseArea {
                    id: folderPointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WallpaperState.openWallpaperFolder()
                }
            }
        }

        ShellText {
            width: parent.width
            text: WallpaperState.error || (WallpaperState.busy ? "Applying wallpaper…" : "~/Pictures/Wallpapers")
            color: Style.muted
            elide: Text.ElideRight
        }

        GridView {
            id: wallpaperGrid
            width: parent.width
            height: parent.height - 70
            cellWidth: width / 3
            cellHeight: 105
            clip: true
            model: WallpaperState.wallpapers
            keyNavigationWraps: true
            Keys.onLeftPressed: root.moveSelection(-1)
            Keys.onRightPressed: root.moveSelection(1)
            Keys.onUpPressed: root.moveSelection(-3)
            Keys.onDownPressed: root.moveSelection(3)
            Keys.onReturnPressed: if (currentItem) currentItem.activate()
            Keys.onEnterPressed: if (currentItem) currentItem.activate()
            Keys.onSpacePressed: if (currentItem) currentItem.activate()

            delegate: Item {
                id: wallpaperTile
                required property int index
                required property var modelData
                width: wallpaperGrid.cellWidth
                height: wallpaperGrid.cellHeight

                function activate() {
                    WallpaperState.setWallpaper(modelData.path);

                }

                ClippingRectangle {
                    id: previewContent

                    anchors.fill: parent
                    anchors.margins: 4
                    radius: Style.radiusSmall
                    color: "transparent"
                    contentUnderBorder: true
                    border.width: wallpaperGrid.currentIndex === index ? 2 : 1
                    border.color: wallpaperGrid.currentIndex === index ? Style.primary : Style.bg3

                    Image {
                        anchors.fill: parent
                        source: wallpaperTile.modelData.url
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: wallpaperGrid.currentIndex = wallpaperTile.index
                    onClicked: wallpaperTile.activate()
                }
            }

            ShellText {
                anchors.centerIn: parent
                width: parent.width - 40
                visible: WallpaperState.wallpapers.length === 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Style.muted
                text: "No wallpapers in\n~/Pictures/Wallpapers"
            }
        }
    }
}
