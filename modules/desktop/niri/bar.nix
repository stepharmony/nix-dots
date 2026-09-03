# Niri/Wayland session only — ironbar status bar.
# Config and CSS live in dotfiles/niri/ironbar/, spawned by config.kdl with
# explicit repo paths (-c/-t), so nothing is deployed into $HOME.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = [ pkgs.ironbar ];
  };
}
