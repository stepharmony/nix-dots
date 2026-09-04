# Niri/Wayland session only — SwayNotificationCenter (swaync) with persistent
# notification history, plus libnotify for notify-send. Daemon and CSS are
# spawned with repo config paths from config.kdl (-c/-s).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];
}
