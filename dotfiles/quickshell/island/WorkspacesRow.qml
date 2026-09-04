// Workspace dots — one per workspace, click to focus. Active dot stretches.
import QtQuick;

Row {
    spacing: 5;

    Repeater {
        model: Wm.workspaces;

        delegate: Rectangle {
            id: dot;

            required property var modelData;

            readonly property bool active: modelData.id === Wm.activeId;

            width: active ? 18 : 11;
            height: 11;
            radius: 5;
            color: active ? Theme.accent : Theme.bgAlt;
            border {
                color: active ? Theme.accent : Theme.outline;
                width: 1;
            }

            Behavior on width {
                NumberAnimation {
                    duration: 150;
                    easing.type: Easing.OutCubic;
                }
            }

            MouseArea {
                anchors.fill: parent;
                cursorShape: Qt.PointingHandCursor;

                onClicked: Wm.focusWorkspace(dot.modelData.id);
            }
        }
    }
}
