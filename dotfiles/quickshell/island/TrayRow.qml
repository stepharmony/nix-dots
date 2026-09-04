// System tray (StatusNotifier) icons — NetworkManager applet and friends.
import Quickshell;
import Quickshell.Services.SystemTray;
import Quickshell.Widgets;
import QtQuick;

Row {
    spacing: 8;

    Repeater {
        model: SystemTray.items;

        delegate: IconImage {
            id: trayIcon;

            required property var modelData;

            source: trayIcon.modelData.icon;
            implicitSize: 18;

            MouseArea {
                anchors.fill: parent;
                cursorShape: Qt.PointingHandCursor;

                onClicked: trayIcon.modelData.activate();
            }
        }
    }
}
