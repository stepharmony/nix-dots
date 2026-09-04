# Wayland session stack (Niri + Hyprland) — Gruvbox theming.
# GTK theme/icons via a NixOS dconf profile (NixOS-native GTK theming — no
# home-manager involved). KDE-side theming stays in Plasma's own settings;
# under Niri the GTK apps follow this profile. The cursor theme is left at
# the system default (no per-session override is possible without leaking
# into Plasma).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gruvbox-gtk-theme
    gruvbox-dark-icons-gtk
  ];

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Gruvbox-Dark";
          icon-theme = "oomox-gruvbox-dark";
          color-scheme = "prefer-dark";
        };
      };
    }
  ];
}
