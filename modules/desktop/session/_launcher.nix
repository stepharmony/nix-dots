# Tiling-session launcher — rofi 2.x (native Wayland in niri, X11 in qtile):
# apps, clipboard picker (niri) and, later, the wallpaper picker. Config
# deployed by hjem to ~/.config/rofi/config.rasi.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rofi ];
}
