// Compositor detection. The island is compositor-agnostic by construction;
// this singleton only picks which polling adapter Wm.qml uses and lets the
// UI label things.
pragma Singleton
import Quickshell;

Singleton {
    readonly property bool isNiri: (Quickshell.env("NIRI_SOCKET") ?? "") !== "";
    readonly property bool isHyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "") !== "";

    readonly property string kind: isNiri ? "niri" : (isHyprland ? "hyprland" : "unknown");
}
