// Compositor adapter: workspaces + focused window, polled once a second.
// Two tiny backends behind one interface — no compositor-specific protocols
// anywhere else in the island. v1 keeps this dead simple (one-shot queries);
// event-stream sockets are an upgrade path if 1s latency ever bothers anyone.
pragma Singleton
import Quickshell;
import Quickshell.Io;
import QtQuick;

Singleton {
    id: root;

    // [{ id, name }] — id doubles as the focus target.
    property var workspaces: [];
    property int activeId: 1;
    property string focusedTitle: "";
    property string focusedClass: "";

    function focusWorkspace(id: int): void {
        if (Env.isNiri) {
            niriFocus.exec(["niri", "msg", "action", "focus-workspace", String(id)]);
        } else if (Env.isHyprland) {
            hyprFocus.exec(["hyprctl", "dispatch", "workspace", String(id)]);
        }
    }

    function refresh(): void {
        if (Env.isNiri) {
            wsQuery.exec(["niri", "msg", "-j", "workspaces"]);
            fwQuery.exec(["niri", "msg", "-j", "focused-window"]);
        } else if (Env.isHyprland) {
            wsQuery.exec(["hyprctl", "-j", "workspaces"]);
            awQuery.exec(["hyprctl", "-j", "activeworkspace"]);
            fwQuery.exec(["hyprctl", "-j", "activewindow"]);
        }
    }

    Process {
        id: wsQuery;

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = JSON.parse(this.text);
                    root.workspaces = Env.isNiri
                        ? list.map(w => ({ id: w.idx, name: w.name || String(w.idx) }))
                        : list.map(w => ({ id: w.id, name: w.name || String(w.id) }));
                } catch (_) {}
            }
        }
    }

    Process {
        id: awQuery;

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.activeId = JSON.parse(this.text).id;
                } catch (_) {}
            }
        }
    }

    Process {
        id: fwQuery;

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const w = JSON.parse(this.text);
                    root.focusedTitle = w.title ?? "";
                    root.focusedClass = w.class ?? w.app_id ?? "";
                } catch (_) {
                    root.focusedTitle = "";
                    root.focusedClass = "";
                }
            }
        }
    }

    Process {
        id: niriFocus;
    }

    Process {
        id: hyprFocus;
    }

    Timer {
        interval: 1000;
        running: Env.kind !== "unknown";
        repeat: true;
        triggeredOnStart: true;

        onTriggered: root.refresh();
    }
}
