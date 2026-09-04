// Power row — reuses the session wrappers: lock (swaylock), hibernate
// (host-aware wrapper), exit (wm-exit), reboot, poweroff.
import Quickshell.Io;
import QtQuick;

Row {
    id: powerRow;

    spacing: 10;

    Process {
        id: cmd;
    }

    function run(prog: string): void {
        cmd.exec(prog.split(" "));
    }

    PillButton {
        label: "\uf023"; // lock

        onClicked: powerRow.run("swaylock");
    }

    PillButton {
        label: "\uf4fd"; // hibernate

        onClicked: powerRow.run("hibernate");
    }

    PillButton {
        label: "\uf906"; // log out

        onClicked: powerRow.run("wm-exit");
    }

    PillButton {
        label: "\uf021"; // reboot

        onClicked: powerRow.run("systemctl reboot");
    }

    PillButton {
        label: "\uf011"; // power off

        onClicked: powerRow.run("systemctl poweroff");
    }
}
