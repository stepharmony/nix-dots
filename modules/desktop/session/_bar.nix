# Wayland session stack (Niri + Hyprland) — ironbar status bar.
# Config and CSS are deployed by hjem to the default ~/.config/ironbar/
# location, so config.kdl / hyprland.lua spawn it with no arguments.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ironbar ];

  # ironbar's text + icon font: JetBrains Mono with the full Nerd Font
  # glyph set — one font covers bar text and module icons alike.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
