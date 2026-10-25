# Wayland session stack (Niri) — waybar, spawned by config.kdl. Config
# deployed by hjem to ~/.config/waybar/ (dotfiles/waybar/).
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.waybar ];

  # Bar, launcher and notification font: JetBrains Mono with the full Nerd
  # Font glyph set — one font covers text and module icons alike.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
