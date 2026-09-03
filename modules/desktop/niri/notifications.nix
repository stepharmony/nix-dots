# Niri/Wayland session only — SwayNotificationCenter (swaync) with persistent
# notification history, plus libnotify for notify-send. Daemon and CSS are
# spawned with repo config paths from config.kdl (-c/-s).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = with pkgs; [
      swaynotificationcenter
      libnotify
    ];
  };
}
