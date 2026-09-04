// Notification toasts — top-right of the primary screen. Transparent window,
// only the toast box grabs input (so popups never eat clicks around them).
import Quickshell;
import QtQuick;

PanelWindow {
    id: root;

    anchors {
        top: true;
        right: true;
    }
    margins {
        top: 6;
        right: 6;
    }
    exclusionMode: ExclusionMode.Ignore;
    color: "transparent";
    implicitWidth: 340;
    implicitHeight: 110;

    mask: Region {
        item: toastBox;
    }

    Rectangle {
        id: toastBox;

        anchors {
            right: parent.right;
            top: parent.top;
        }
        width: 320;
        height: toastCol.implicitHeight + 24;
        radius: 14;
        color: Theme.bg;
        border {
            color: Theme.outline;
            width: 1;
        }
        opacity: Notifs.toast !== null ? 1 : 0;

        Behavior on opacity {
            NumberAnimation {
                duration: 180;
                easing.type: Easing.OutCubic;
            }
        }

        Column {
            id: toastCol;

            anchors.fill: parent;
            anchors.margins: 12;
            spacing: 4;

            Text {
                width: parent.width;
                text: Notifs.toast?.summary ?? "";
                color: Theme.fg;
                font.family: Theme.fontName;
                font.pixelSize: 12;
                font.bold: true;
                elide: Text.ElideRight;
            }

            Text {
                width: parent.width;
                text: Notifs.toast?.body ?? "";
                color: Theme.fgDim;
                font.family: Theme.fontName;
                font.pixelSize: 11;
                wrapMode: Text.Wrap;
                maximumLineCount: 3;
                elide: Text.ElideRight;
            }
        }

        MouseArea {
            anchors.fill: parent;
            cursorShape: Qt.PointingHandCursor;

            onClicked: Notifs.dismissToast();
        }
    }
}
