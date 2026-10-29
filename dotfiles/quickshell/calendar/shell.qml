// Calendar popup for the niri session, after Plasma's clock calendar: the
// selected day's events (evolution-data-server, i.e. what GNOME Calendar
// shows), a few time zones, and a day / month / year grid. Runs as
// `qs -c calendar` (spawned by niri); waybar's clock toggles it. Closes on
// Escape or a click outside, unless pinned.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        visible: Cal.open
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        // Stays below waybar, so the clock still gets its click.
        exclusionMode: ExclusionMode.Normal
        color: "transparent"
        WlrLayershell.namespace: "calendar"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: Cal.pinned ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive
        // Pinned, only the card takes input; the rest of the screen works.
        mask: Region {
            item: Cal.pinned ? card : backdrop
        }

        MouseArea {
            id: backdrop
            anchors.fill: parent
            onClicked: Cal.hide()
        }

        Rectangle {
            id: card
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            width: 860
            height: 490
            radius: 10
            color: Theme.bg
            border.color: Theme.line
            border.width: 1
            clip: true
            focus: true
            Keys.onEscapePressed: Cal.hide()

            // Clicks on the card stay on the card.
            MouseArea {
                anchors.fill: parent
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0

                // ── left: date, events, time zones ──
                ColumnLayout {
                    id: leftPane
                    Layout.preferredWidth: 410
                    Layout.fillHeight: true
                    spacing: 0

                    Text {
                        Layout.leftMargin: 16
                        Layout.topMargin: 12
                        Layout.bottomMargin: 8
                        text: Cal.now.toLocaleDateString(Cal.locale, "dddd, d MMMM yyyy")
                        color: Theme.fg
                        font.pixelSize: 21
                    }

                    SectionHeader {
                        title: Cal.sameDay(Cal.selected, Cal.now) ? "Events" : "Events · " + Cal.selected.toLocaleDateString(Cal.locale, "ddd d MMM")
                        TextButton {
                            text: "+  Add…"
                            onClicked: {
                                Quickshell.execDetached(["gnome-calendar"]);
                                Cal.hide();
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: Cal.selectedEvents
                        topMargin: 6

                        delegate: Item {
                            id: event
                            required property var modelData
                            width: ListView.view.width
                            height: Math.max(body.implicitHeight, 36) + 14

                            Rectangle {
                                x: 16
                                y: 6
                                width: 4
                                height: parent.height - 12
                                radius: 2
                                color: event.modelData.color || Theme.accent
                            }
                            // Times on the left; title with the description
                            // (grey, two lines at most) beside them.
                            Row {
                                id: body
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 30
                                anchors.rightMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                Column {
                                    id: times
                                    spacing: 2
                                    Text {
                                        text: Cal.startLabel(event.modelData, Cal.selected)
                                        color: Theme.fg
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        visible: text !== ""
                                        text: Cal.endLabel(event.modelData, Cal.selected)
                                        color: Theme.fgDim
                                        font.pixelSize: 13
                                    }
                                }
                                Column {
                                    width: parent.width - times.width - parent.spacing
                                    spacing: 2
                                    Text {
                                        width: parent.width
                                        text: event.modelData.summary
                                        elide: Text.ElideRight
                                        color: Theme.fg
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        width: parent.width
                                        visible: text !== ""
                                        text: event.modelData.description || ""
                                        textFormat: Text.PlainText
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        color: Theme.fgDim
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: parent.count === 0
                            text: "No events"
                            color: Theme.muted
                            font.pixelSize: 14
                        }
                    }

                    SectionHeader {
                        title: "Time Zones"
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8

                        Repeater {
                            model: Cal.zones

                            delegate: Rectangle {
                                id: zone
                                required property var modelData
                                readonly property bool local: modelData.offsetMinutes === 0
                                width: parent.width
                                height: 30
                                color: zoneHover.hovered ? Theme.bgHigh : "transparent"

                                HoverHandler {
                                    id: zoneHover
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: zone.modelData.city
                                    color: Theme.fg
                                    font.pixelSize: 14
                                    font.bold: zone.local
                                }
                                Row {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6
                                    Text {
                                        text: zone.modelData.time
                                        color: Theme.fg
                                        font.pixelSize: 14
                                        font.bold: zone.local
                                    }
                                    Text {
                                        visible: !zone.local
                                        text: "· " + Cal.relative(zone.modelData.offsetMinutes)
                                        color: Theme.fgDim
                                        font.pixelSize: 13
                                        anchors.baseline: parent.children[0].baseline
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: Theme.line
                }

                // ── right: the grid ──
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 6
                            text: {
                                if (Cal.mode === "years")
                                    return Cal.decade + " – " + (Cal.decade + 9);
                                if (Cal.mode === "months")
                                    return Cal.viewYear;
                                const month = Cal.capital(Cal.locale.standaloneMonthName(Cal.viewMonth, Locale.LongFormat));
                                return Cal.viewYear === Cal.now.getFullYear() ? month : month + " " + Cal.viewYear;
                            }
                            color: Theme.fg
                            font.pixelSize: 21
                        }
                        TextButton {
                            text: "󰐃"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 17
                            active: Cal.pinned
                            dim: !Cal.pinned
                            onClicked: Cal.pinned = !Cal.pinned
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        TextButton {
                            text: "Days"
                            active: Cal.mode === "days"
                            onClicked: Cal.mode = "days"
                        }
                        TextButton {
                            text: "Months"
                            active: Cal.mode === "months"
                            onClicked: Cal.mode = "months"
                        }
                        TextButton {
                            text: "Years"
                            active: Cal.mode === "years"
                            onClicked: Cal.mode = "years"
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        TextButton {
                            text: "‹"
                            font.pixelSize: 20
                            onClicked: Cal.step(-1)
                        }
                        TextButton {
                            text: "Today"
                            onClicked: Cal.goToday()
                        }
                        TextButton {
                            text: "›"
                            font.pixelSize: 20
                            onClicked: Cal.step(1)
                        }
                    }

                    // Days
                    GridLayout {
                        visible: Cal.mode === "days"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 0
                        columnSpacing: 0

                        Repeater {
                            model: 7
                            delegate: Text {
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                Layout.preferredWidth: 1
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: Cal.capital(Cal.locale.dayName((Cal.locale.firstDayOfWeek + index) % 7, Locale.ShortFormat))
                                color: Theme.fgDim
                                font.pixelSize: 15
                            }
                        }

                        Repeater {
                            model: 42
                            delegate: Rectangle {
                                id: cell
                                required property int index
                                readonly property var day: Cal.addDays(Cal.gridStart(Cal.viewYear, Cal.viewMonth), index)
                                readonly property var events: Cal.eventsByDay[Cal.iso(day)] || []
                                readonly property int timed: events.filter(ev => !ev.allDay).length
                                readonly property bool allDay: events.some(ev => ev.allDay)
                                readonly property bool isToday: Cal.sameDay(day, Cal.now)
                                readonly property bool isSelected: Cal.sameDay(day, Cal.selected)
                                readonly property bool inMonth: day.getMonth() === Cal.viewMonth

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 1
                                Layout.margins: 2
                                radius: 8
                                color: isSelected ? (isToday ? Theme.accent : Theme.bgHigh) : dayArea.containsMouse ? Theme.bgAlt : "transparent"
                                border.width: isToday && !isSelected ? 1 : 0
                                border.color: Theme.accent

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: number.top
                                    anchors.bottomMargin: 1
                                    spacing: 3
                                    Rectangle {
                                        visible: cell.allDay
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 14
                                        height: 3
                                        radius: 1.5
                                        color: number.color
                                        opacity: 0.8
                                    }
                                    Repeater {
                                        model: Math.min(cell.timed, 5)
                                        delegate: Rectangle {
                                            width: 4
                                            height: 4
                                            radius: 2
                                            color: number.color
                                            opacity: 0.8
                                        }
                                    }
                                }
                                Text {
                                    id: number
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 4
                                    text: cell.day.getDate()
                                    font.pixelSize: 18
                                    font.bold: cell.isToday
                                    color: cell.isSelected && cell.isToday ? Theme.accentText : cell.isToday ? Theme.accent : cell.inMonth ? Theme.fg : Theme.muted
                                }
                                MouseArea {
                                    id: dayArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Cal.pickDay(cell.day)
                                    onDoubleClicked: {
                                        Quickshell.execDetached(["gnome-calendar"]);
                                        Cal.hide();
                                    }
                                }
                            }
                        }
                    }

                    // Months and Years: 3 × 4 tiles
                    GridLayout {
                        visible: Cal.mode !== "days"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 8
                        columns: 3
                        rowSpacing: 4
                        columnSpacing: 4

                        Repeater {
                            model: 12
                            delegate: Rectangle {
                                id: tile
                                required property int index
                                // Years: the decade plus a year either side, dimmed.
                                readonly property int value: Cal.mode === "months" ? index : Cal.decade - 1 + index
                                readonly property bool current: Cal.mode === "months" ? Cal.viewYear === Cal.now.getFullYear() && value === Cal.now.getMonth() : value === Cal.now.getFullYear()
                                readonly property bool chosen: Cal.mode === "months" ? value === Cal.viewMonth : value === Cal.viewYear

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 1
                                radius: 8
                                color: chosen ? Theme.bgHigh : tileArea.containsMouse ? Theme.bgAlt : "transparent"
                                border.width: current ? 1 : 0
                                border.color: Theme.accent

                                Text {
                                    anchors.centerIn: parent
                                    text: Cal.mode === "months" ? Cal.capital(Cal.locale.standaloneMonthName(tile.value, Locale.LongFormat)) : tile.value
                                    font.pixelSize: 17
                                    color: tile.current ? Theme.accent : Cal.mode === "years" && (tile.index === 0 || tile.index === 11) ? Theme.muted : Theme.fg
                                }
                                MouseArea {
                                    id: tileArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Cal.mode === "months" ? Cal.pickMonth(tile.value) : Cal.pickYear(tile.value)
                                }
                            }
                        }
                    }
                }
            }

            // The wheel flips pages — over the grid side only, so the event
            // list's overscroll doesn't. On top of the grid but click- and
            // hover-transparent. A page per notch; touchpad deltas add up.
            MouseArea {
                property real pending: 0
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.leftMargin: leftPane.width + 2
                acceptedButtons: Qt.NoButton
                onWheel: wheel => {
                    pending += wheel.angleDelta.y;
                    while (Math.abs(pending) >= 120) {
                        Cal.step(pending > 0 ? -1 : 1);
                        pending -= pending > 0 ? 120 : -120;
                    }
                }
            }
        }
    }
}
