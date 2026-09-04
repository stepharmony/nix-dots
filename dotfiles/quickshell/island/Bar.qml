// The island pill: collapsed (workspace dots + clock), expands on hover or
// via Mod+N (notification center). The window is a fixed transparent layer
// surface centered by the compositor (top-anchored only); only the pill box
// itself grabs input via the mask, so animated size never touches layer-shell
// resizing.
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
    exclusiveZone: 40;
    color: "transparent";
    implicitWidth: Theme.panelWidth + 40;
    implicitHeight: 420;

    mask: Region {
        item: pillBox;
    }

    readonly property bool expanded: hoverArea.containsMouse || Notifs.centerOpen;

    Rectangle {
        id: pillBox;

        anchors {
            horizontalCenter: parent.horizontalCenter;
            top: parent.top;
        }
        width: root.expanded ? Theme.panelWidth : Theme.barWidth;
        height: topRow.height + (root.expanded ? panelColumn.height + 12 : 0);
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
                margins: 10;
            }
            height: Theme.barHeight - 14;

            WorkspacesRow {
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

        // Expanded panel.
        Column {
            id: panelColumn;

            anchors {
                top: topRow.bottom;
                left: parent.left;
                right: parent.right;
                margins: 12;
            }
            spacing: 12;
            visible: height > 0;
            height: root.expanded ? implicitHeight : 0;

            Behavior on height {
                NumberAnimation {
                    duration: 220;
                    easing.type: Easing.OutCubic;
                }
            }

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

                Behavior on height {
                    NumberAnimation {
                        duration: 180;
                        easing.type: Easing.OutCubic;
                    }
                }
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
