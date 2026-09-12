import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland
import qs
import qs.components

Column {
    id: root
    spacing: 10
    property bool dragging: false
    property var windows: Tasks.windows.result.windows || []
    Component.onCompleted: Tasks.windows.start(["windows"])
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            refresh.restart();
        }
    }
    Timer {
        id: refresh
        interval: 180
        onTriggered: if (!root.dragging)
            Tasks.windows.start(["windows"])
    }
    BodyText {
        text: "Workspaces"
        font.pixelSize: 22
    }
    BodyText {
        width: parent.width
        text: "Click a workspace or window to focus it. Drag a window card onto another workspace."
        color: Style.muted
    }
    Grid {
        id: workspaceGrid
        width: parent.width
        columns: width > 760 ? 5 : 2
        spacing: 10
        Repeater {
            model: 10
            delegate: Rectangle {
                id: workspace
                required property int index
                readonly property int number: index + 1
                width: (workspaceGrid.width - (workspaceGrid.columns - 1) * 10) / workspaceGrid.columns
                height: 190
                radius: 20
                color: target.containsDrag ? Style.bg3 : Style.bg1
                border.width: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === number ? 2 : 0
                border.color: Style.primary
                DropArea {
                    id: target
                    anchors.fill: parent
                    keys: ["hshell-window"]
                    onDropped: drop => {
                        if (drop.source && drop.source.address) {
                            Tasks.windowAction.start(["move-window", drop.source.address, String(workspace.number)]);
                            drop.acceptProposedAction();
                        }
                    }
                }
                Column {
                    x: 8
                    y: 8
                    width: parent.width - 16
                    spacing: 5
                    PillButton {
                        width: parent.width
                        text: "Workspace " + workspace.number
                        implicitHeight: 34
                        onClicked: {
                            Tasks.windowAction.start(["workspace", String(workspace.number)]);
                            ShellState.close();
                        }
                    }
                    Flickable {
                        width: parent.width
                        height: 135
                        contentHeight: cards.implicitHeight
                        clip: true
                        Column {
                            id: cards
                            width: parent.width
                            spacing: 5
                            Repeater {
                                model: root.windows.filter(w => w.workspace && w.workspace.id === workspace.number)
                                delegate: Item {
                                    id: holder
                                    required property var modelData
                                    width: cards.width
                                    height: 46
                                    Rectangle {
                                        id: tile
                                        property string address: holder.modelData.address
                                        width: holder.width
                                        height: holder.height
                                        radius: 12
                                        color: Style.bg3
                                        Drag.active: pointer.drag.active
                                        Drag.keys: ["hshell-window"]
                                        Drag.source: tile
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2
                                        BodyText {
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            text: holder.modelData.title || holder.modelData.class
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            font.pixelSize: 12
                                        }
                                        MouseArea {
                                            id: pointer
                                            anchors.fill: parent
                                            drag.target: tile
                                            onPressed: {
                                                const point = tile.mapToItem(dragLayer, 0, 0);
                                                tile.parent = dragLayer;
                                                root.dragging = true;
                                                tile.x = point.x;
                                                tile.y = point.y;
                                                tile.z = 100;
                                            }
                                            onReleased: {
                                                const moved = drag.active;
                                                tile.Drag.drop();
                                                root.dragging = false;
                                                tile.parent = holder;
                                                tile.x = 0;
                                                tile.y = 0;
                                                if (!moved) {
                                                    Tasks.windowAction.start(["focus-window", tile.address]);
                                                    ShellState.close();
                                                }
                                            }
                                            onCanceled: {
                                                root.dragging = false;
                                                tile.parent = holder;
                                                tile.x = 0;
                                                tile.y = 0;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Item {
        id: dragLayer
        width: 0
        height: 0
        z: 100
    }

    TaskStatus {
        width: parent.width
        task: Tasks.windowAction
    }
}
