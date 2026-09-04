# Hyprland session core.
{ ... }:

{
  # SDDM session + xdg-desktop-portal-hyprland.
  #
  # UWSM wraps the compositor in systemd units: it imports the session env
  # (HYPRLAND_INSTANCE_SIGNATURE, XDG_CURRENT_DESKTOP, ...) into the systemd
  # user manager and starts graphical-session.target — which per-user units
  # like xremap-bridge require. A bare "Hyprland" session from SDDM does
  # neither, so always pick "Hyprland (UWSM)" in the greeter.
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
}
