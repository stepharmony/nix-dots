# Niri/Wayland session only — session utility binaries used by binds in
# config.kdl: screenshots, media/brightness keys, clipboard management.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = with pkgs; [
      grim
      slurp
      playerctl
      brightnessctl
      cliphist
      wl-clipboard
    ];
  };
}
