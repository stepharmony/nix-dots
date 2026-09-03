# Niri — scrollable-tiling Wayland compositor, alongside Plasma.
# Adds a SDDM session; plasma.nix pins the SDDM default to Plasma.
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
{
  config,
  lib,
  ...
}:

{
  options.features.desktop.niri.enable =
    lib.mkEnableOption "the Niri Wayland compositor as an additional SDDM session";

  config = lib.mkIf config.features.desktop.niri.enable {
    # SDDM session, xdg portals (screencast via portal-gnome), gnome-keyring,
    # and niri's integrated xwayland for X11 apps. The nixpkgs module
    # mkDefaults the SDDM default session to niri — plasma.nix overrides.
    programs.niri.enable = true;
  };
}
