# Wayland session stack (Niri) — island carrier. The custom quickshell
# island is the bar and the notification daemon, spawned by config.kdl as
# `qs -c island` (QML deployed by hjem to ~/.config/quickshell/island).
#
# matugen derives the island's palette from the current wallpaper.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    quickshell
    matugen
  ];

  # Island text + icon font: JetBrains Mono with the full Nerd Font
  # glyph set — one font covers pill text and module icons alike.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
