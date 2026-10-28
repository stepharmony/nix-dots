# Calendar for the tiling sessions — GNOME Calendar on evolution-data-server
# (EDS), with Google synced through GNOME Online Accounts: add the account
# once with `gnome-online-accounts-gtk` (no GNOME Settings here). Clicking
# waybar's clock opens the calendar.
#
# Reminders: EDS's evolution-alarm-notify shows them as ordinary
# notifications (mako/dunst). niri starts its user unit through
# graphical-session.target; qtile's autostart runs `calendar-reminders`;
# XFCE picks up the XDG autostart entry by itself.
{ pkgs, ... }:

{
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-calendar
    gnome-online-accounts-gtk
    # The notifier lives in libexec, off PATH.
    (writeShellScriptBin "calendar-reminders" ''
      exec ${evolution-data-server}/libexec/evolution-data-server/evolution-alarm-notify "$@"
    '')
  ];

  systemd.user.services.evolution-alarm-notify.wantedBy = [ "graphical-session.target" ];
}
