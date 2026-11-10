// Notification daemon for the niri session (replaces mako), run as
// `qs -c notif` (spawned by niri): owns org.freedesktop.Notifications.
// Popups stack under waybar, top right, and time out of view; everything
// stays tracked (capped) for the swaync-style side panel, toggled with
// `qs ipc -c notif call notifs toggle` (Mod+Shift+N). The panel closes on
// Escape or a click outside; `... clear` dismisses everything.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

ShellRoot {
    id: root

    property bool panelOpen: false
    readonly property int maxTracked: 50
    readonly property int defaultTimeout: 6000

    function clearAll() {
        // dismiss() drops the entry from the model while we walk it.
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            const all = server.trackedNotifications.values;
            if (all.length > root.maxTracked)
                all[0].dismiss();
        }
    }

    IpcHandler {
        target: "notifs"

        function toggle(): void {
            root.panelOpen = !root.panelOpen;
        }
        function clear(): void {
            root.clearAll();
        }
    }

    // ── popups ──
    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 6
            right: 10
        }
        implicitWidth: 360
        // Always mapped: cards in a hidden window count as invisible, so the
        // list would never grow to show it. Empty, it is 1px and click-through.
        implicitHeight: Math.max(1, popups.contentHeight)
        // Below waybar's exclusive zone, not over it.
        exclusionMode: ExclusionMode.Normal
        color: "transparent"
        WlrLayershell.namespace: "notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        // Only the cards take input. Not contentItem: bottom-to-top, the
        // delegates sit at negative y outside its bounds. The window is sized
        // to the cards, so the whole list is the right region.
        mask: Region {
            item: popups
        }

        ListView {
            id: popups
            anchors.fill: parent
            interactive: false
            // The model is oldest first; newest goes on top.
            verticalLayoutDirection: ListView.BottomToTop
            model: server.trackedNotifications

            delegate: Item {
                id: slot
                required property Notification modelData
                property bool expired: false
                readonly property bool shown: !expired && !root.panelOpen

                width: ListView.view.width
                height: shown ? card.implicitHeight + 8 : 0
                visible: shown

                NotifCard {
                    id: card
                    width: parent.width
                    notif: slot.modelData
                }

                // expireTimeout: 0 never, <0 server default. Milliseconds, as
                // sent over D-Bus — quickshell documents seconds but passes
                // the raw value through (notification.cpp, updateProperties).
                Timer {
                    running: !card.critical && slot.modelData.expireTimeout !== 0 && !card.hovered
                    interval: slot.modelData.expireTimeout > 0 ? slot.modelData.expireTimeout : root.defaultTimeout
                    onTriggered: slot.expired = true
                }
            }
        }
    }

    // ── side panel ──
    PanelWindow {
        visible: root.panelOpen
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Normal
        // Dimmed and blurred behind (niri, ext-background-effect-v1); the
        // compositor only does the work while the panel is open.
        color: "#33000000"
        WlrLayershell.namespace: "notification-center"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        BackgroundEffect.blurRegion: Region {
            item: backdrop
        }

        MouseArea {
            id: backdrop
            anchors.fill: parent
            onClicked: root.panelOpen = false
        }

        Rectangle {
            id: panel
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 6
                rightMargin: 10
            }
            width: 400
            radius: 10
            color: Theme.bg
            border.color: Theme.line
            border.width: 1
            focus: true
            Keys.onEscapePressed: root.panelOpen = false

            // Clicks on the panel stay on the panel.
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Theme.fg
                        font.family: "Obel Mono"
                        font.pixelSize: 18
                    }
                    Rectangle {
                        visible: history.count > 0
                        implicitWidth: clearLabel.implicitWidth + 20
                        implicitHeight: 28
                        radius: 6
                        color: clearArea.containsMouse ? Theme.bgHigh : Theme.bgAlt

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "Clear all"
                            color: Theme.fg
                            font.family: "Obel Mono"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.clearAll()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: history.count === 0
                    text: "No notifications"
                    color: Theme.muted
                    font.family: "Obel Mono"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                ListView {
                    id: history
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: count > 0
                    clip: true
                    spacing: 8
                    // Newest first, without flipping the layout to the bottom.
                    model: server.trackedNotifications.values.slice().reverse()

                    delegate: NotifCard {
                        required property Notification modelData
                        width: ListView.view.width
                        notif: modelData
                    }
                }
            }
        }
    }
}
