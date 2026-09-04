# Wayland session stack (Niri + Hyprland) — sunsetr blue-light filter
# (redshift-style). Config deployed by hjem to the default
# ~/.config/sunsetr location.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.sunsetr ];
}
