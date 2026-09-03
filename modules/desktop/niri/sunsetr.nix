# Niri/Wayland session only — sunsetr blue-light filter (redshift-style).
# Niri gets this daemon; Plasma keeps its built-in Night Color.
# Config lives in dotfiles/niri/sunsetr/, passed via --config on the
# spawn-at-startup line in config.kdl.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = [ pkgs.sunsetr ];
  };
}
