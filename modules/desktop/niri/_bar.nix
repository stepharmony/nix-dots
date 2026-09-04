# Niri/Wayland session only — ironbar status bar.
# Config and CSS live in dotfiles/niri/ironbar/, spawned by config.kdl with
# explicit repo paths (-c/-t), so nothing is deployed into $HOME.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ironbar ];

  # ironbar's text + icon font: JetBrains Mono with the full Nerd Font
  # glyph set — one font covers bar text and module icons alike.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
