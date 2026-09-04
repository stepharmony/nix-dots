// Island theme: matugen palette with gruvbox fallbacks. The palette file is
// written by `matugen image <wallpaper>` (see dotfiles/matugen/) into
// $XDG_STATE_HOME/island/colors.json; watchChanges recolors live, without an
// island restart. Before matugen's first run (or if it fails) the pill simply
// stays gruvbox.
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell;
import Quickshell.Io;
import QtQuick;

Singleton {
    id: root;

    // Material roles — gruvbox fallbacks everywhere.
    readonly property string bg: pal.mSurface || "#282828";
    readonly property string bgAlt: pal.mSurfaceVariant || "#3c3836";
    readonly property string bgDeep: pal.mShadow || "#1d2021";
    readonly property string fg: pal.mOnSurface || "#ebdbb2";
    readonly property string fgDim: pal.mOnSurfaceVariant || "#a89984";
    readonly property string accent: pal.mPrimary || "#98971a"; // gruvbox active green
    readonly property string onAccent: pal.mOnPrimary || "#1d2021";
    readonly property string outline: pal.mOutline || "#3c3836";
    readonly property string hover: pal.mHover || "#3c3836";
    readonly property string error: pal.mError || "#cc241d";

    // Metrics. collapsedWidth must never exceed expandedWidth — the Bar
    // derives them so hover can't oscillate.
    readonly property int pillRadius: 22;
    readonly property int barHeight: 44;
    readonly property int collapsedWidth: 340;
    readonly property int expandedWidth: 460;
    readonly property string fontName: "JetBrainsMono Nerd Font";

    FileView {
        id: paletteFile;

        path: `${Quickshell.env("XDG_STATE_HOME") ?? (Quickshell.env("HOME") + "/.local/state")}/island/colors.json`;
        watchChanges: true;

        onFileChanged: paletteFile.reload();

        JsonAdapter {
            id: pal;

            property string mPrimary: "";
            property string mOnPrimary: "";
            property string mSecondary: "";
            property string mOnSecondary: "";
            property string mSurface: "";
            property string mOnSurface: "";
            property string mSurfaceVariant: "";
            property string mOnSurfaceVariant: "";
            property string mOutline: "";
            property string mHover: "";
            property string mError: "";
            property string mShadow: "";
        }
    }
}
