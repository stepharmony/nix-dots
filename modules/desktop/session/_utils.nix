# Wayland session stack (Niri) — utilities used by config.kdl: clipboard
# (wl-clipboard + cliphist history), media/brightness keys, wallpaper.
# Screenshots use niri's built-in UI (Print / Ctrl+Print / Alt+Print).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    cliphist
    playerctl
    brightnessctl
    swaybg
  ];
}
