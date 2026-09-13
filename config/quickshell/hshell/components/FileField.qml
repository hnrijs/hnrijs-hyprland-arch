import QtQuick
import qs

Field {
    id: root
    property string caption: "File path"
    property alias path: root.text
    placeholderText: caption + " · drop a file or enter its path"
    DropArea {
        anchors.fill: parent
        onDropped: drop => {
            if (drop.hasUrls)
                root.text = drop.urls[0];
        }
    }
}
