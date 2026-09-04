// Volume slider (PipeWire default sink) + mute, brightness ± buttons via
// brightnessctl (this quickshell build has no Brightness module).
import Quickshell.Io;
import Quickshell.Services.Pipewire;
import QtQuick;
import QtQuick.Controls;

Row {
    id: root;

    spacing: 10;

    readonly property var sink: Pipewire.defaultAudioSink;

    // Nodes must be tracked to be bound — without this, volume/mute writes
    // fail with "PwNode ... which is not bound".
    PwObjectTracker {
        objects: root.sink ? [root.sink] : [];
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter;
        text: "vol";
        color: root.sink?.audio?.muted ?? false ? Theme.error : Theme.fgDim;
        font.family: Theme.fontName;
        font.pixelSize: 11;
    }

    Slider {
        id: volSlider;

        width: parent.width - 150;
        anchors.verticalCenter: parent.verticalCenter;
        from: 0;
        to: 1;
        value: root.sink?.audio?.volume ?? 0;
        enabled: root.sink !== null;

        onMoved: {
            if (root.sink) {
                root.sink.audio.volume = volSlider.value;
                root.sink.audio.muted = false;
            }
        }
    }

    PillButton {
        label: "m";
        labelSize: 11;

        onClicked: {
            if (root.sink) {
                root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter;
        text: "bri";
        color: Theme.fgDim;
        font.family: Theme.fontName;
        font.pixelSize: 11;
    }

    PillButton {
        label: "-";
        labelSize: 14;

        onClicked: briProc.exec(["brightnessctl", "set", "5%-"]);
    }

    PillButton {
        label: "+";
        labelSize: 14;

        onClicked: briProc.exec(["brightnessctl", "set", "5%+"]);
    }

    Process {
        id: briProc;
    }
}
