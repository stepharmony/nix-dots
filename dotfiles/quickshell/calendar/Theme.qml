// Wallpaper palette — colors.json is rendered next to this file by matugen
// (`wallpaper`, modules/desktop/session/_theming.nix) and re-read on change.
// The defaults only show until the first `wallpaper init`.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme

    property color bg: "#13140d"
    property color bgAlt: "#1f201a"
    property color bgHigh: "#2a2b22"
    property color fg: "#e5e3d6"
    property color fgDim: "#c8c7b7"
    property color accent: "#c4cd7b"
    property color accentText: "#2e3300"
    property color muted: "#929282"
    property color line: "#47483b"

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/calendar/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            let c;
            try {
                c = JSON.parse(text());
            } catch (e) {
                return;
            }
            theme.bg = c.bg;
            theme.bgAlt = c.bg_alt;
            theme.bgHigh = c.bg_high;
            theme.fg = c.fg;
            theme.fgDim = c.fg_dim;
            theme.accent = c.accent;
            theme.accentText = c.on_accent;
            theme.muted = c.muted;
            theme.line = c.line;
        }
    }
}
