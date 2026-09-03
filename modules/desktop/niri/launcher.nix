# Niri/Wayland session only — rofi launcher (Wayland-native since 2.0).
# Config lives in dotfiles/niri/rofi/config.rasi, passed via -config on the
# bind in config.kdl.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = [ pkgs.rofi ];
  };
}
