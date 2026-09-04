// Notification history list (shown in the expanded island when Mod+N toggled).
pragma ComponentBehavior: Bound

import QtQuick;

ListView {
    id: root;

    spacing: 6;
    model: Notifs.history;
    clip: true;

    delegate: Rectangle {
        id: card;

        required property var modelData;

        width: root.width;
        height: cardCol.implicitHeight + 16;
        radius: 10;
        color: Theme.bgAlt;

        Column {
            id: cardCol;

            anchors.fill: parent;
            anchors.margins: 8;
            spacing: 2;

            Text {
                width: parent.width;
                text: (card.modelData.appName !== "" ? card.modelData.appName + "  ·  " : "") + card.modelData.summary;
                color: Theme.fg;
                font.family: Theme.fontName;
                font.pixelSize: 12;
                font.bold: true;
                elide: Text.ElideRight;
            }

            Text {
                width: parent.width;
                text: card.modelData.body;
                color: Theme.fgDim;
                font.family: Theme.fontName;
                font.pixelSize: 11;
                elide: Text.ElideRight;
                visible: card.modelData.body !== "";
            }
        }
    }

    Text {
        anchors.centerIn: parent;
        text: "no notifications yet";
        color: Theme.fgDim;
        font.family: Theme.fontName;
        font.pixelSize: 11;
        visible: Notifs.history.length === 0;
    }
}
