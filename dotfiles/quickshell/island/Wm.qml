// Compositor adapter: workspaces + focused window, polled once a second.
// niri-only — the queries come straight from `niri msg -j`, focus via
// `niri msg action focus-workspace`.
pragma Singleton
import Quickshell;
import Quickshell.Io;
import QtQuick;

Singleton {
    id: root;

    readonly property bool running: (Quickshell.env("NIRI_SOCKET") ?? "") !== "";

    // [{ id, name }] — id doubles as the focus target.
    property var workspaces: [];
    property int activeId: 1;
    property string focusedTitle: "";
    property string focusedClass: "";

    function focusWorkspace(id: int): void {
        focus.exec(["niri", "msg", "action", "focus-workspace", String(id)]);
    }

    function refresh(): void {
        wsQuery.exec(["niri", "msg", "-j", "workspaces"]);
        fwQuery.exec(["niri", "msg", "-j", "focused-window"]);
    }

    Process {
        id: focus;
    }

    Process {
        id: wsQuery;

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaces = JSON.parse(this.text).map(w => ({
                            id: w.idx,
                            name: w.name || String(w.idx)
                        }));
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

    Timer {
        interval: 1000;
        running: root.running;
        repeat: true;
        triggeredOnStart: true;

        onTriggered: root.refresh();
    }
}
