# Hyprland session core.
{ ... }:

{
  # SDDM session + xdg-desktop-portal-hyprland. No UWSM: the session stack
  # is spawned from hyprland.lua's hyprland.start hook, like the Niri session
  # spawns from config.kdl.
  programs.hyprland.enable = true;
}
