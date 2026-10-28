"""Reads the calendars GNOME Calendar shows (evolution-data-server) for the
Quickshell calendar popup; prints JSON on stdout.

  calendar-events events <first-day> <last-day>   ISO dates, both inclusive
  calendar-events zones <Area/City>...            time now in each zone
"""

import json
import sys
from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

LOCAL = datetime.now().astimezone().tzinfo


def to_local(t):
    """ICalTime -> (aware local datetime, all-day?)."""
    from gi.repository import ICalGLib

    if t.is_date():
        return datetime(t.get_year(), t.get_month(), t.get_day(), tzinfo=LOCAL), True
    zone = t.get_timezone() or ICalGLib.Timezone.get_utc_timezone()
    stamp = t.as_timet_with_zone(zone)
    return datetime.fromtimestamp(stamp, LOCAL), False


def events(first, last):
    # Imported here so `zones` (run every minute) skips loading EDS.
    import gi

    gi.require_version("EDataServer", "1.2")
    gi.require_version("ECal", "2.0")
    gi.require_version("ICalGLib", "3.0")
    from gi.repository import ECal, EDataServer

    start = datetime.combine(first, time.min, LOCAL)
    end = datetime.combine(last + timedelta(days=1), time.min, LOCAL)
    registry = EDataServer.SourceRegistry.new_sync(None)
    found = {}
    for source in registry.list_enabled(EDataServer.SOURCE_EXTENSION_CALENDAR):
        ext = source.get_extension(EDataServer.SOURCE_EXTENSION_CALENDAR)
        # Calendars unticked in GNOME Calendar stay hidden here too.
        if not ext.get_selected():
            continue
        try:
            client = ECal.Client.connect_sync(source, ECal.ClientSourceType.EVENTS, 10, None)
        except Exception as err:  # offline account, broken backend, ...
            print(f"calendar-events: {source.get_display_name()}: {err}", file=sys.stderr)
            continue

        def instance(comp, inst_start, inst_end, *_):
            s, all_day = to_local(inst_start)
            e, _ = to_local(inst_end) if inst_end and not inst_end.is_null_time() else (s, all_day)
            # Ends right where the range starts: not in it.
            if e == start and e > s:
                return True
            # The same calendar subscribed twice (e.g. holidays) shows once.
            found[(comp.get_summary(), s, e, source.get_display_name())] = {
                "summary": comp.get_summary() or "",
                "start": s.isoformat(),
                "end": e.isoformat(),
                "allDay": all_day,
                "color": ext.get_color() or "",
                "calendar": source.get_display_name(),
            }
            return True

        client.generate_instances_sync(int(start.timestamp()), int(end.timestamp()), None, instance)
    return sorted(found.values(), key=lambda ev: (ev["start"], not ev["allDay"]))


def zones(names):
    now = datetime.now(LOCAL)
    local_offset = now.utcoffset()
    out = []
    for name in names:
        there = now.astimezone(ZoneInfo(name))
        out.append(
            {
                "zone": name,
                "city": name.rsplit("/", 1)[-1].replace("_", " "),
                "time": there.strftime("%H:%M"),
                "offsetMinutes": int((there.utcoffset() - local_offset).total_seconds() // 60),
            }
        )
    return out


def main(argv):
    if len(argv) == 3 and argv[0] == "events":
        result = events(date.fromisoformat(argv[1]), date.fromisoformat(argv[2]))
    elif argv and argv[0] == "zones":
        result = zones(argv[1:])
    else:
        print(__doc__.strip(), file=sys.stderr)
        return 1
    json.dump(result, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
