# Tiling-session default apps (niri + qtile; XFCE keeps its own). Chosen
# to be GTK3 or toolkit-free, so the per-session
# theming (GTK_THEME / qt6ct, set only by niri and qtile) fully applies.
# Defaults per session: dotfiles/xdg/tiling-mimeapps.list, deployed as
# niri-mimeapps.list and qtile-mimeapps.list (XDG reads those only when
# XDG_CURRENT_DESKTOP matches, so XFCE's defaults are untouched).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty # terminal: ligatures, transparency (dotfiles/kitty/kitty.conf)
    xarchiver # archives (also Thunar's right-click extract/compress)
    zathura # PDF (keyboard-driven); Okular stays for annotations
    imv # images
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.tumbler.enable = true; # thumbnails
  services.gvfs.enable = true; # trash, removable drives, network mounts
}
