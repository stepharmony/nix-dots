# Niri/Wayland session only — Gruvbox theming.
# GTK theme/icon/cursor via a NixOS dconf profile (NixOS-native GTK theming —
# no home-manager involved). KDE-side theming stays in Plasma's own settings;
# under Niri the GTK apps follow this profile.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.features.desktop.niri.enable {
    environment.systemPackages = with pkgs; [
      gruvbox-gtk-theme
      gruvbox-dark-icons-gtk
      bibata-cursors
    ];

    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Gruvbox-Dark";
            icon-theme = "oomox-gruvbox-dark";
            cursor-theme = "Bibata-Modern-Amber";
            color-scheme = "prefer-dark";
          };
        };
      }
    ];
  };
}
