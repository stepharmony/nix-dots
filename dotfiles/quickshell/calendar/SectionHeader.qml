// Shaded heading row ("Events", "Time Zones"); children sit on the right.
import QtQuick
import QtQuick.Layouts

Rectangle {
    property alias title: label.text
    default property alias actions: actionRow.data

    Layout.fillWidth: true
    implicitHeight: 42
    color: Theme.bgAlt

    Text {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.fg
        font.pixelSize: 17
    }

    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }
}
