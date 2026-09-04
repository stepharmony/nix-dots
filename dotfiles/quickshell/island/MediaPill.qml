// MPRIS media row: now playing + transport controls for the first player.
import Quickshell.Services.Mpris;
import QtQuick;

Row {
    id: media;

    spacing: 10;

    readonly property var players: Mpris.players?.values ?? [];
    readonly property var player: players.length > 0 ? players[0] : null;

    visible: media.player !== null;

    Text {
        width: parent.width - 96;
        anchors.verticalCenter: parent.verticalCenter;
        text: media.player ? ((media.player.trackArtist ?? "") !== "" ? media.player.trackArtist + " — " : "") + (media.player.trackTitle ?? "") : "";
        color: Theme.fg;
        font.family: Theme.fontName;
        font.pixelSize: 12;
        elide: Text.ElideRight;
    }

    PillButton {
        label: "\u23ee"; // ⏮
        visible: media.player?.canGoPrevious ?? false;

        onClicked: media.player.previous();
    }

    PillButton {
        label: media.player?.playbackState === MprisPlaybackState.Playing ? "\u23f8" : "\u25b6"; // ⏸ ▶
        visible: media.player?.canTogglePlaying ?? false;

        onClicked: media.player.togglePlaying();
    }

    PillButton {
        label: "\u23ed"; // ⏭
        visible: media.player?.canGoNext ?? false;

        onClicked: media.player.next();
    }
}
