# Calendar for the tiling sessions — GNOME Calendar on evolution-data-server
# (EDS), with Google synced through GNOME Online Accounts: add the account
# once with `gnome-online-accounts-gtk` (no GNOME Settings here).
#
# In niri, waybar's clock toggles a Quickshell popup modelled on Plasma's
# clock calendar (dotfiles/quickshell/calendar/, run as `qs -c calendar`);
# it reads the same EDS calendars through `calendar-events` below. Its
# "Add…" button, a double-clicked day and a right-click on the clock open
# GNOME Calendar. qtile keeps its own clock.
#
# Reminders: EDS's evolution-alarm-notify shows them as ordinary
# notifications (mako/dunst). niri starts its user unit through
# graphical-session.target; qtile's autostart runs `calendar-reminders`;
# XFCE picks up the XDG autostart entry by itself.
{
  pkgs,
  lib,
  username,
  ...
}:
let
  popup = ../../../dotfiles/quickshell/calendar;

  # calendar-events events <first> <last> | zones <Area/City>... -> JSON
  calendarEvents =
    let
      python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
      typelibs = map lib.getLib (
        with pkgs;
        [
          evolution-data-server
          libical
          glib
          gobject-introspection
          libsoup_3
          json-glib
          libxml2
          libsecret
        ]
      );
    in
    pkgs.writeShellScriptBin "calendar-events" ''
      export GI_TYPELIB_PATH=${lib.makeSearchPath "lib/girepository-1.0" typelibs}
      exec ${python}/bin/python3 ${./_calendar-events.py} "$@"
    '';
in
{
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-calendar
    gnome-online-accounts-gtk
    quickshell
    calendarEvents
    # The notifier lives in libexec, off PATH.
    (writeShellScriptBin "calendar-reminders" ''
      exec ${evolution-data-server}/libexec/evolution-data-server/evolution-alarm-notify "$@"
    '')
  ];

  systemd.user.services.evolution-alarm-notify.wantedBy = [ "graphical-session.target" ];

  # File by file, so the directory stays writable for matugen's colors.json.
  hjem.users.${username}.xdg.config.files = lib.mapAttrs' (
    name: _: lib.nameValuePair "quickshell/calendar/${name}" { source = popup + "/${name}"; }
  ) (builtins.readDir popup);
}
