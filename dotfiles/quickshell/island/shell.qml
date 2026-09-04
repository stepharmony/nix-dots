// Island — a minimalist gruvbox dynamic island for niri and Hyprland,
// built on quickshell's compositor-agnostic APIs only (no hyprctl/niri
// internals except the small polling adapters in Wm.qml).
import Quickshell;
import Quickshell.Io;
import QtQuick;

ShellRoot {
    Variants {
        model: Quickshell.screens;

        delegate: Bar {
            screen: modelData;
        }
    }

    // Toasts render on the first screen only.
    Toasts {
        screen: Quickshell.screens[0] ?? null;
    }

    IpcHandler {
        target: "island";

        function toggleNotifCenter(): void {
            Notifs.centerOpen = !Notifs.centerOpen;
        }

        function openNotifCenter(): void {
            Notifs.centerOpen = true;
        }
    }
}
