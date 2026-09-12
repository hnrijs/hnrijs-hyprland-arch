pragma Singleton
import QtQuick
import Quickshell
import qs

Singleton {
    readonly property var palettes: {
        "mocha": ["#1e1e2e", "#313244", "#45475a", "#cdd6f4", "#a6adc8", "#89b4fa"],
        "monochrome": ["#080808", "#222222", "#444444", "#ffffff", "#bbbbbb", "#ffffff"],
        "tokyo": ["#1a1b26", "#292e42", "#414868", "#c0caf5", "#a9b1d6", "#7aa2f7"],
        "gruvbox": ["#282828", "#3c3836", "#504945", "#ebdbb2", "#bdae93", "#83a598"],
        "nord": ["#2e3440", "#3b4252", "#4c566a", "#eceff4", "#d8dee9", "#88c0d0"]
    }
    readonly property var palette: palettes[Preferences.theme] || palettes.mocha
    readonly property color bgDim: palette[0]
    readonly property color bg0: palette[0]
    readonly property color bg1: palette[1]
    readonly property color bg2: palette[1]
    readonly property color bg3: palette[2]
    readonly property color bg4: palette[2]
    readonly property color foreground: palette[3]
    readonly property color muted: palette[4]
    readonly property color mutedDark: palette[4]
    readonly property color primary: palette[5]
    readonly property color activeFill: "#f5f5f7"
    readonly property color activeText: "#1e1e2e"
    readonly property color primaryContainer: palette[1]
    readonly property color shellBackground: bg0
    readonly property color shellForeground: foreground
    readonly property color bgGreen: bg1
    readonly property color bgYellow: bg1
    readonly property color red: primary
    readonly property color green: primary
    readonly property color blue: primary
    readonly property color yellow: primary
    readonly property color orange: primary
    readonly property color purple: primary
    readonly property color aqua: primary
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: fontFamily
    readonly property int fontSize: 14
    readonly property int radius: 28
    readonly property int radiusSmall: 18
    readonly property int animationFast: 160
    readonly property int animationNormal: 260
}
