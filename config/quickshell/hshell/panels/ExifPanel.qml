import QtQuick
import qs
import qs.components

Column {
    spacing: 12
    FileField {
        id: source
        width: parent.width
        caption: "Choose File"
    }
    Row {
        width: parent.width
        spacing: 8
        PillButton {
            width: (parent.width - 8) / 2
            text: "View Metadata"
            enabled: !Tasks.exif.running
            onClicked: Tasks.exif.start(["exif", "view", source.path])
        }
        PillButton {
            width: (parent.width - 8) / 2
            text: "Remove Metadata"
            enabled: !Tasks.exif.running
            onClicked: Tasks.exif.start(["exif", "remove", source.path])
        }
    }
    BodyText {
        width: parent.width
        text: "Removal creates a clean copy beside the original."
        color: Style.muted
    }
    TaskStatus {
        width: parent.width
        task: Tasks.exif
    }
    BodyText {
        width: parent.width
        text: Tasks.exif.result.text || Tasks.exif.result.path || ""
        textFormat: Text.PlainText
    }
}
