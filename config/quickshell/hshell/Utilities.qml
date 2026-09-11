pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string scripts: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/scripts/"
    readonly property var entries: [
    {
        "category": "system",
        "title": "Audio",
        "subtitle": "Volume, microphone, Wi-Fi and Bluetooth",
        "kind": "panel",
        "value": "control",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Power",
        "subtitle": "Lock, suspend, log out and shut down",
        "kind": "panel",
        "value": "power",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Notifications",
        "subtitle": "Recent messages and do not disturb",
        "kind": "panel",
        "value": "notifications",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Wallpapers",
        "subtitle": "Choose from Pictures/Wallpapers",
        "kind": "panel",
        "value": "wallpaper",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Tools",
        "subtitle": "Search utilities",
        "kind": "panel",
        "value": "tools",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Network / DNS",
        "subtitle": "Edit NetworkManager connections",
        "kind": "terminal",
        "value": "network",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Bluetooth terminal",
        "subtitle": "Pair and inspect Bluetooth devices",
        "kind": "terminal",
        "value": "bluetooth",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Monitors",
        "subtitle": "List outputs, modes and positions",
        "kind": "terminal",
        "value": "monitors",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Keyboard devices",
        "subtitle": "Inspect input devices",
        "kind": "terminal",
        "value": "keyboard",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "US keyboard",
        "subtitle": "Use US layout for this session",
        "kind": "terminal",
        "value": "keyboard-us",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Latvian keyboard",
        "subtitle": "Use LV layout for this session",
        "kind": "terminal",
        "value": "keyboard-lv",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "System info",
        "subtitle": "Hardware and operating system",
        "kind": "terminal",
        "value": "info",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "System update",
        "subtitle": "Review and install Arch updates",
        "kind": "terminal",
        "value": "update",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "System cleanup",
        "subtitle": "Review unused packages and old cache",
        "kind": "terminal",
        "value": "clean",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Install apps",
        "subtitle": "Search repository packages",
        "kind": "terminal",
        "value": "install-app",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Remove apps",
        "subtitle": "Choose installed packages; review removal",
        "kind": "terminal",
        "value": "remove-app",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Firewall status",
        "subtitle": "Inspect UFW rules",
        "kind": "terminal",
        "value": "firewall",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Enable firewall",
        "subtitle": "Enable UFW in a terminal",
        "kind": "terminal",
        "value": "firewall-enable",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Disable firewall",
        "subtitle": "Disable UFW in a terminal",
        "kind": "terminal",
        "value": "firewall-disable",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Hyprland settings",
        "subtitle": "Edit the main configuration",
        "kind": "terminal",
        "value": "edit-hypr",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Local settings",
        "subtitle": "Edit monitor and device overrides",
        "kind": "terminal",
        "value": "edit-local",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "Stay awake",
        "subtitle": "Toggle automatic idle timers",
        "kind": "script",
        "value": "idle-toggle.sh",
        "icon": "›"
    },
    {
        "category": "system",
        "title": "GTK appearance",
        "subtitle": "Choose the GTK theme used by Thunar",
        "kind": "exec",
        "value": [
            "nwg-look"
        ],
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Disk usage",
        "subtitle": "Inspect files in your home folder",
        "kind": "terminal",
        "value": "disk",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Processes",
        "subtitle": "CPU, memory and process monitor",
        "kind": "terminal",
        "value": "processes",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Find files",
        "subtitle": "Search home and open a file",
        "kind": "terminal",
        "value": "find-file",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Find text",
        "subtitle": "Search file contents in your home folder",
        "kind": "terminal",
        "value": "find-text",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Downloader",
        "subtitle": "Audio, video, files, magnets and repositories",
        "kind": "terminal",
        "value": "downloader",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Media tools",
        "subtitle": "Inspect, convert, resize, rotate and trim",
        "kind": "terminal",
        "value": "media",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Weather",
        "subtitle": "Enter a location in the terminal",
        "kind": "terminal",
        "value": "weather",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Speed test",
        "subtitle": "Measure network speed",
        "kind": "terminal",
        "value": "speed",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Periodic table",
        "subtitle": "Find an element and copy its symbol",
        "kind": "terminal",
        "value": "periodic",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Calculator",
        "subtitle": "Type an expression in the launcher",
        "kind": "panel",
        "value": "launcher",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Calendar",
        "subtitle": "Browse months",
        "kind": "panel",
        "value": "calendar",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Quick notes",
        "subtitle": "Create and edit Markdown notes",
        "kind": "panel",
        "value": "notes",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Clipboard",
        "subtitle": "Search clipboard history",
        "kind": "panel",
        "value": "clipboard",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Emoji",
        "subtitle": "Copy an emoji",
        "kind": "panel",
        "value": "emoji",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Web shortcuts",
        "subtitle": "Open a website",
        "kind": "panel",
        "value": "web",
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Color picker",
        "subtitle": "Pick a screen color and copy its value",
        "kind": "exec",
        "value": [
            "hyprpicker",
            "-a"
        ],
        "icon": "›"
    },
    {
        "category": "tools",
        "title": "Files",
        "subtitle": "Open Thunar",
        "kind": "exec",
        "value": [
            "thunar"
        ],
        "icon": "›"
    },
    {
        "category": "web",
        "title": "YouTube",
        "subtitle": "https://youtube.com",
        "kind": "url",
        "value": "https://youtube.com",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "Reddit",
        "subtitle": "https://reddit.com",
        "kind": "url",
        "value": "https://reddit.com",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "GitHub",
        "subtitle": "https://github.com",
        "kind": "url",
        "value": "https://github.com",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "Gemini",
        "subtitle": "https://gemini.google.com",
        "kind": "url",
        "value": "https://gemini.google.com",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "Maps",
        "subtitle": "https://google.com/maps",
        "kind": "url",
        "value": "https://google.com/maps",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "Translate",
        "subtitle": "https://translate.google.com",
        "kind": "url",
        "value": "https://translate.google.com",
        "icon": "›"
    },
    {
        "category": "web",
        "title": "Windy",
        "subtitle": "https://windy.com",
        "kind": "url",
        "value": "https://windy.com",
        "icon": "›"
    },
    {
        "category": "emoji",
        "title": "Smile",
        "subtitle": "Copy 😀",
        "kind": "copy",
        "value": "😀",
        "icon": "😀"
    },
    {
        "category": "emoji",
        "title": "Laugh",
        "subtitle": "Copy 😂",
        "kind": "copy",
        "value": "😂",
        "icon": "😂"
    },
    {
        "category": "emoji",
        "title": "Heart",
        "subtitle": "Copy ♥",
        "kind": "copy",
        "value": "♥",
        "icon": "♥"
    },
    {
        "category": "emoji",
        "title": "Thumbs up",
        "subtitle": "Copy 👍",
        "kind": "copy",
        "value": "👍",
        "icon": "👍"
    },
    {
        "category": "emoji",
        "title": "Check",
        "subtitle": "Copy ✓",
        "kind": "copy",
        "value": "✓",
        "icon": "✓"
    },
    {
        "category": "emoji",
        "title": "Fire",
        "subtitle": "Copy 🔥",
        "kind": "copy",
        "value": "🔥",
        "icon": "🔥"
    },
    {
        "category": "emoji",
        "title": "Party",
        "subtitle": "Copy 🎉",
        "kind": "copy",
        "value": "🎉",
        "icon": "🎉"
    },
    {
        "category": "emoji",
        "title": "Thinking",
        "subtitle": "Copy 🤔",
        "kind": "copy",
        "value": "🤔",
        "icon": "🤔"
    },
    {
        "category": "emoji",
        "title": "Eyes",
        "subtitle": "Copy 👀",
        "kind": "copy",
        "value": "👀",
        "icon": "👀"
    },
    {
        "category": "emoji",
        "title": "Wave",
        "subtitle": "Copy 👋",
        "kind": "copy",
        "value": "👋",
        "icon": "👋"
    },
    {
        "category": "emoji",
        "title": "Thanks",
        "subtitle": "Copy 🙏",
        "kind": "copy",
        "value": "🙏",
        "icon": "🙏"
    },
    {
        "category": "emoji",
        "title": "Hundred",
        "subtitle": "Copy 💯",
        "kind": "copy",
        "value": "💯",
        "icon": "💯"
    }
]
    function run(entry) {
        if (entry.kind === "panel") { ShellState.setPanel(entry.value); return; }
        ShellState.close();
        if (entry.kind === "terminal")
            Quickshell.execDetached(["alacritty", "-e", "bash", scripts + "tools.sh", "terminal", entry.value]);
        else if (entry.kind === "script")
            Quickshell.execDetached(["bash", scripts + entry.value]);
        else if (entry.kind === "exec")
            Quickshell.execDetached(entry.value);
        else if (entry.kind === "url")
            Qt.openUrlExternally(entry.value);
        else if (entry.kind === "copy")
            Quickshell.execDetached(["wl-copy", "--", entry.value]);
    }
}
