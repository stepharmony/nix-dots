# Wayland session stack (Niri) — notification daemon is a Quickshell config
# (dotfiles/quickshell/notif/, run as `qs -c notif`, spawned by config.kdl;
# qtile uses dunst) + libnotify clients (notify-send). mako is not installed:
# its D-Bus activation file would grab the bus whenever qs is not up yet.
{
  pkgs,
  lib,
  username,
  ...
}:
let
  notif = ../../../dotfiles/quickshell/notif;
in
{
  environment.systemPackages = with pkgs; [
    libnotify
    quickshell
  ];

  hjem.users.${username}.xdg.config.files = lib.mapAttrs' (
    name: _: lib.nameValuePair "quickshell/notif/${name}" { source = notif + "/${name}"; }
  ) (builtins.readDir notif);
}
