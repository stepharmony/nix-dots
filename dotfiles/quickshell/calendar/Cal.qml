// Calendar state: what is shown, the events and time-zone clocks (both from
// `calendar-events`, modules/desktop/session/_calendar.nix), and the IPC
// target waybar's clock calls:  qs ipc -c calendar call calendar toggle
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: cal

    // The clocks under "Time Zones"; the local one is shown in bold.
    readonly property var zoneNames: ["America/Chicago", "America/New_York", "Europe/Vienna", "Europe/Bucharest"]

    property bool open: false
    property bool pinned: false // stays open on outside clicks
    property string mode: "days" // days | months | years
    property var now: new Date()
    property var selected: new Date()
    property int viewYear: now.getFullYear()
    property int viewMonth: now.getMonth()
    property var eventsByDay: ({}) // "YYYY-MM-DD" -> events touching that day
    property var zones: []

    readonly property var locale: Qt.locale()
    readonly property var selectedEvents: eventsByDay[iso(selected)] || []
    readonly property int decade: viewYear - viewYear % 10

    function show() {
        now = new Date();
        selected = now;
        viewYear = now.getFullYear();
        viewMonth = now.getMonth();
        mode = "days";
        open = true;
        fetchEvents();
        zonesProc.running = true;
    }

    function hide() {
        open = false;
        pinned = false;
    }

    function pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function iso(d) {
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
    }

    function addDays(d, n) {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate() + n);
    }

    function sameDay(a, b) {
        return iso(a) === iso(b);
    }

    // First cell of the 6-week grid: the week start on or before the 1st.
    function gridStart(year, month) {
        const first = new Date(year, month, 1);
        const back = (first.getDay() - locale.firstDayOfWeek % 7 + 7) % 7;
        return addDays(first, -back);
    }

    // Locale month/day names can be lowercase ("octombrie"); headings aren't.
    function capital(s) {
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    function hhmm(d) {
        return pad(d.getHours()) + ":" + pad(d.getMinutes());
    }

    // Event times as seen from `day`: "…" where it runs past the day's edge.
    function startLabel(ev, day) {
        if (ev.allDay)
            return "All day";
        return sameDay(ev.s, day) ? hhmm(ev.s) : "…";
    }

    function endLabel(ev, day) {
        if (ev.allDay)
            return "";
        return sameDay(ev.e, day) ? hhmm(ev.e) : "…";
    }

    function relative(minutes) {
        if (minutes === 0)
            return "";
        const h = Math.floor(Math.abs(minutes) / 60), m = Math.abs(minutes) % 60;
        const span = (h ? h + (h === 1 ? " hour" : " hours") : "") + (h && m ? " " : "") + (m ? m + " min" : "");
        return span + (minutes < 0 ? " earlier" : " later");
    }

    // ‹ / › — a month, a year or a decade, depending on the view.
    function step(dir) {
        if (mode === "days") {
            const d = new Date(viewYear, viewMonth + dir, 1);
            viewYear = d.getFullYear();
            viewMonth = d.getMonth();
            fetchEvents();
        } else {
            viewYear += mode === "months" ? dir : 10 * dir;
        }
    }

    function goToday() {
        now = new Date();
        selected = now;
        viewYear = now.getFullYear();
        viewMonth = now.getMonth();
        mode = "days";
        fetchEvents();
    }

    function pickDay(day) {
        selected = day;
        if (day.getMonth() !== viewMonth) {
            viewYear = day.getFullYear();
            viewMonth = day.getMonth();
            fetchEvents();
        }
    }

    function pickMonth(month) {
        viewMonth = month;
        mode = "days";
        fetchEvents();
    }

    function pickYear(year) {
        viewYear = year;
        mode = "months";
    }

    function fetchEvents() {
        if (eventsProc.running) {
            eventsProc.again = true;
            return;
        }
        const first = gridStart(viewYear, viewMonth);
        eventsProc.first = iso(first);
        eventsProc.last = iso(addDays(first, 41));
        eventsProc.command = ["calendar-events", "events", eventsProc.first, eventsProc.last];
        eventsProc.running = true;
    }

    // Days already fetched stay cached, so the selected day keeps its
    // events while browsing other months.
    function storeEvents(text, first, last) {
        let list;
        try {
            list = JSON.parse(text);
        } catch (e) {
            return;
        }
        const map = Object.assign({}, eventsByDay);
        for (let d = new Date(first + "T00:00"); iso(d) <= last; d = addDays(d, 1))
            map[iso(d)] = [];
        for (const ev of list) {
            ev.s = new Date(ev.start);
            ev.e = new Date(ev.end);
            // The end is exclusive: an event ending at midnight stays on its day.
            const lastMs = ev.e > ev.s ? ev.e.getTime() - 1 : ev.s.getTime();
            for (let d = new Date(ev.s.getFullYear(), ev.s.getMonth(), ev.s.getDate()); d.getTime() <= lastMs; d = addDays(d, 1)) {
                const key = iso(d);
                if (key >= first && key <= last)
                    map[key].push(ev);
            }
        }
        eventsByDay = map;
    }

    Process {
        id: eventsProc
        property string first
        property string last
        property bool again: false
        stdout: StdioCollector {
            onStreamFinished: cal.storeEvents(text, eventsProc.first, eventsProc.last)
        }
        onExited: {
            if (again) {
                again = false;
                cal.fetchEvents();
            }
        }
    }

    Process {
        id: zonesProc
        command: ["calendar-events", "zones"].concat(cal.zoneNames)
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    cal.zones = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    // Clocks tick while open; the minute is all they show.
    Timer {
        interval: 20000
        repeat: true
        running: cal.open
        onTriggered: {
            cal.now = new Date();
            zonesProc.running = true;
        }
    }

    IpcHandler {
        target: "calendar"

        function toggle(): void {
            if (cal.open)
                cal.hide();
            else
                cal.show();
        }
    }
}
