// Flat text button; `active` underlines it (the Days/Months/Years tabs).
import QtQuick

Rectangle {
    id: button

    property alias text: label.text
    property alias font: label.font
    property bool active: false
    property bool dim: false
    signal clicked

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 32
    radius: 6
    color: area.containsMouse ? Theme.bgHigh : "transparent"

    Text {
        id: label
        anchors.centerIn: parent
        color: button.dim ? Theme.muted : Theme.fg
        font.pixelSize: 15
    }

    Rectangle {
        visible: button.active
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 8
        height: 2
        radius: 1
        color: Theme.accent
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
