# Niri — scrollable-tiling Wayland compositor, alongside Plasma.
# Adds a SDDM session; plasma.nix pins the SDDM default to Plasma.
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # EXPERIMENT: satellite pinned to 0.8.1 — 0.8.2 ships popup regressions
  # that close Steam dropdown menus instantly under Niri (upstream:
  # satellite#468 and the 2026-09 Steam forum thread). If 0.8.1 doesn't
  # help, revert systemPackages to plain pkgs.xwayland-satellite and delete
  # this let block; upstream fix expected in the satellite rewrite.
  #
  # cargoDeps is overridden (not cargoHash) because the vendor derivation is
  # instantiated with the original hash before overrideAttrs can see it.
  satellite081Src = pkgs.fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    tag = "v0.8.1";
    hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
  };

  satellite081 = pkgs.xwayland-satellite.overrideAttrs (old: {
    version = "0.8.1";
    src = satellite081Src;
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      pname = "xwayland-satellite";
      version = "0.8.1";
      src = satellite081Src;
      hash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
    };
  });
in
{
  options.features.desktop.niri.enable =
    lib.mkEnableOption "the Niri Wayland compositor as an additional SDDM session";

  config = lib.mkIf config.features.desktop.niri.enable {
    # SDDM session, xdg portals (screencast via portal-gnome), gnome-keyring,
    # and niri's integrated xwayland for X11 apps. The nixpkgs module
    # mkDefaults the SDDM default session to niri — plasma.nix overrides.
    programs.niri.enable = true;

    # niri spawns xwayland-satellite on demand for X11 apps (Steam, Proton
    # games); the nixpkgs niri package does not depend on it — must be on
    # PATH ourselves. The satellite wrapper brings the real Xwayland along.
    environment.systemPackages = [ satellite081 ];
  };
}
