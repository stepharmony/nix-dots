# Wayland session stack (Niri + Hyprland) — rofi launcher (Wayland-native
# since 2.0). Config deployed by hjem to the default ~/.config/rofi location.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rofi ];
}
