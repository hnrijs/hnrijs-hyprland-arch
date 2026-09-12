pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    property alias color: colorTask
    Task {
        id: colorTask
        onFinished: success => {
            if (success && result.color)
                History.append("colors", result);
        }
    }
    property alias weather: weatherTask
    property alias speed: speedTask
    property alias disks: diskTask
    property alias download: downloadTask
    property alias media: mediaTask
    property alias ip: ipTask
    property alias windows: windowsTask
    property alias windowAction: windowActionTask
    property alias clipboard: clipboardTask
    property alias caffeine: caffeineTask
    Task {
        id: weatherTask
    }
    Task {
        id: speedTask
        onFinished: success => {
            if (success)
                History.append("speed", result);
        }
    }
    Task {
        id: diskTask
    }
    Task {
        id: downloadTask
    }
    Task {
        id: mediaTask
    }
    Task {
        id: ipTask
        onFinished: success => {
            if (success)
                History.append("ip", result);
        }
    }
    Task {
        id: windowsTask
    }
    Task {
        id: windowActionTask
        onFinished: success => {
            if (success)
                windowsTask.start(["windows"]);
        }
    }
    Task {
        id: clipboardTask
        onFinished: success => {
            if (success) {
                Backend.clipboardContents = "";
                Backend.clipboardImageSource = "";
                Backend.refreshClipboard();
            }
        }
    }
    Task {
        id: caffeineTask
    }
    Component.onCompleted: caffeineTask.start(["caffeine"])
}
