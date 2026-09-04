// The island pill: collapsed (workspace dots + clock), expands on hover or
// via Mod+N (notification center). The window is a fixed transparent layer
// surface centered by the compositor (top-anchored only); only the pill box
// itself grabs input via the mask, so animated size never touches layer-shell
// resizing. pillBox is the single animation source.
import Quickshell;
import QtQuick;

PanelWindow {
    id: root;

    required property var modelData;

    screen: modelData;
    anchors {
        top: true;
    }
    margins {
        top: 6;
    }
    exclusionMode: ExclusionMode.Normal;
    exclusiveZone: 44;
    color: "transparent";
    implicitWidth: Theme.expandedWidth + 40;
    implicitHeight: 480;

    mask: Region {
        item: pillBox;
    }

    readonly property bool expanded: hoverArea.containsMouse || Notifs.centerOpen;

    Rectangle {
        id: pillBox;

        // Content-derived collapsed width — can never exceed the expanded
        // width, so hover can't oscillate between the two states.
        readonly property real collapsedWidth: Math.max(Theme.collapsedWidth, wsRow.width + clockText.implicitWidth + 40);

        anchors {
            horizontalCenter: parent.horizontalCenter;
            top: parent.top;
        }
        width: root.expanded ? Math.max(Theme.expandedWidth, collapsedWidth) : collapsedWidth;
        height: root.expanded ? 8 + topRow.height + 12 + panelColumn.implicitHeight : Theme.barHeight;
        radius: Theme.pillRadius;
        color: Theme.bg;
        border {
            color: Theme.outline;
            width: 1;
        }
        clip: true;

        Behavior on width {
            NumberAnimation {
                duration: 220;
                easing.type: Easing.OutCubic;
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 220;
                easing.type: Easing.OutCubic;
            }
        }

        MouseArea {
            id: hoverArea;

            anchors.fill: parent;
            hoverEnabled: true;
            acceptedButtons: Qt.NoButton;
        }

        // Collapsed row — always visible.
        Item {
            id: topRow;

            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
                margins: 8;
            }
            height: 28;

            WorkspacesRow {
                id: wsRow;

                anchors {
                    left: parent.left;
                    verticalCenter: parent.verticalCenter;
                }
            }

            SystemClock {
                id: clock;

                precision: SystemClock.Minutes;
            }

            Text {
                id: clockText;

                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                }
                text: Qt.formatDateTime(clock.date, "ddd  HH:mm");
                color: Theme.fg;
                font.family: Theme.fontName;
                font.pixelSize: 13;
            }
        }

        // Expanded panel — the pill box animates; this column snaps.
        Column {
            id: panelColumn;

            anchors {
                top: topRow.bottom;
                left: parent.left;
                right: parent.right;
                margins: 12;
            }
            spacing: 12;
            visible: root.expanded;
            height: implicitHeight;

            Text {
                width: parent.width;
                text: Wm.focusedTitle;
                color: Theme.fgDim;
                font.family: Theme.fontName;
                font.pixelSize: 12;
                elide: Text.ElideRight;
                visible: Wm.focusedTitle !== "";
            }

            MediaPill {
                width: parent.width;
            }

            SlidersPill {
                width: parent.width;
            }

            NotifCenter {
                width: parent.width;
                visible: Notifs.centerOpen;
                height: visible ? 180 : 0;
                clip: true;
            }

            TrayRow {
                width: parent.width;
            }

            PowerRow {
                width: parent.width;
            }
        }
    }
}
