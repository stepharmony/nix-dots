// Notification daemon + shared notif state. The island IS the notification
// daemon: swaync is retired once this is validated. quickshell auto-acknowledges
// received notifications after their expire timeout — we only snapshot them for
// the toast and the history list.
pragma Singleton
import Quickshell;
import Quickshell.Services.Notifications;
import QtQuick;

Singleton {
    id: root;

    property bool centerOpen: false;
    // [{ summary, body, appName }] — newest first, capped.
    property var history: [];
    property var toast: null;

    onToastChanged: {
        if (root.toast) {
            toastTimer.restart();
        }
    }

    function dismissToast(): void {
        root.toast = null;
    }

    Timer {
        id: toastTimer;

        interval: 5000;

        onTriggered: root.toast = null;
    }

    NotificationServer {
        id: server;

        keepOnReload: false;
        bodySupported: true;
        bodyMarkupSupported: true;
        imageSupported: true;

        onNotification: n => {
            root.history = [{
                    summary: n.summary ?? "",
                    body: n.body ?? "",
                    appName: n.appName ?? ""
                }].concat(root.history).slice(0, 30);
            root.toast = {
                summary: n.summary ?? "",
                body: n.body ?? ""
            };
        }
    }
}
