# Niri session core: SDDM session, xdg portals, gnome-keyring, integrated
# xwayland, plus the pinned xwayland-satellite for X11 apps.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # CONFIRMED PIN (2026-09-03): satellite 0.8.2's popup regression closes Steam
  # dropdown menus instantly under Niri (satellite#468; 2026-09 Steam forum
  # thread). 0.8.1 verified working. REMOVE this pin when nixpkgs ships a fixed
  # satellite release — then revert to plain pkgs.xwayland-satellite and check
  # Steam dropdowns in a Niri session before deleting this comment.
  #
  # cargoDeps is overridden (not cargoHash) because the vendor derivation is
  # instantiated with the original hash before overrideAttrs can reach it.
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
  # SDDM session, xdg portals (screencast via portal-gnome), gnome-keyring,
  # and niri's integrated xwayland for X11 apps. The nixpkgs module
  # mkDefaults the SDDM default session to niri — desktop.nix overrides.
  programs.niri.enable = true;

  # niri spawns xwayland-satellite on demand for X11 apps (Steam, Proton
  # games); the nixpkgs niri package does not depend on it — must be on
  # PATH ourselves. The satellite wrapper brings the real Xwayland along.
  environment.systemPackages = [ satellite081 ];
}
