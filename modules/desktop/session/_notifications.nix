# Wayland session stack (Niri) — SwayNotificationCenter (swaync)
# with persistent notification history, plus libnotify for notify-send.
# Daemon and CSS are spawned from the default ~/.config/swaync location
# (deployed by hjem).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];
}
