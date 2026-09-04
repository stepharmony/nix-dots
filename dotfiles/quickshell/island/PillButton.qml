// Small round-ish button used all over the island.
import QtQuick;

Rectangle {
    id: root;

    property string label: "";
    property real labelSize: 13;
    signal clicked();

    width: 26;
    height: 24;
    radius: 8;
    color: mouse.containsMouse ? Theme.hover : "transparent";

    Text {
        anchors.centerIn: parent;
        text: root.label;
        color: Theme.fg;
        font.family: Theme.fontName;
        font.pixelSize: root.labelSize;
    }

    MouseArea {
        id: mouse;

        anchors.fill: parent;
        hoverEnabled: true;
        cursorShape: Qt.PointingHandCursor;

        onClicked: root.clicked();
    }
}
