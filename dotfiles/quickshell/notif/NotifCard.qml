// One notification, as a popup or a row in the side panel. Clicking the body
// runs the default action (if any) and dismisses; × just dismisses.
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Rectangle {
    id: card

    required property Notification notif
    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property alias hovered: hover.hovered

    implicitHeight: content.implicitHeight + 20
    radius: 8
    color: Theme.bg
    border.width: 2
    border.color: critical ? "#9b0000" : Theme.line

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            const def = card.notif.actions.find(a => a.identifier === "default");
            if (def && mouse.button === Qt.LeftButton)
                def.invoke();
            card.notif.dismiss();
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: card.notif.appName
                color: Theme.muted
                font.family: "Obel Mono"
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: close.containsMouse ? Theme.bgHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Theme.fgDim
                    font.pixelSize: 16
                }
                MouseArea {
                    id: close
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.notif.dismiss()
                }
            }
        }
        Text {
            Layout.fillWidth: true
            text: card.notif.summary
            color: Theme.fg
            font.family: "Obel Mono"
            font.pixelSize: 14
            font.bold: true
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
        }
        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: card.notif.body
            color: Theme.fgDim
            font.family: "Obel Mono"
            font.pixelSize: 12
            wrapMode: Text.Wrap
            textFormat: Text.StyledText
            maximumLineCount: 6
            elide: Text.ElideRight
        }
        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: actionRepeater.count > 0

            Repeater {
                id: actionRepeater
                // "default" is the body click.
                model: card.notif.actions.filter(a => a.identifier !== "default")
                delegate: Rectangle {
                    id: button
                    required property var modelData
                    implicitWidth: label.implicitWidth + 20
                    implicitHeight: 26
                    radius: 6
                    color: area.containsMouse ? Theme.bgHigh : Theme.bgAlt

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: button.modelData.text
                        color: Theme.fg
                        font.family: "Obel Mono"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: button.modelData.invoke()
                    }
                }
            }
        }
    }
}
