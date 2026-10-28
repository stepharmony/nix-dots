# Wayland session stack (Niri) — mako notification daemon (spawned by
# config.kdl; qtile uses dunst) + libnotify clients (notify-send).
# Config deployed by hjem to ~/.config/mako/config.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mako
    libnotify
  ];
}
