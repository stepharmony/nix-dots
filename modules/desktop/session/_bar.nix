# Wayland session stack (Niri + Hyprland) — status layer. ironbar is still
# present until the custom quickshell island is validated; the island is
# spawned by config.kdl / hyprland.lua as `qs -c island` (QML deployed by
# hjem to ~/.config/quickshell/island).
#
# matugen derives the island's palette from the current wallpaper.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ironbar
    quickshell
    matugen
  ];

  # Bar/island text + icon font: JetBrains Mono with the full Nerd Font
  # glyph set — one font covers bar text and module icons alike.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
