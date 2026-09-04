# Niri — scrollable-tiling Wayland compositor, alongside Plasma.
# The compositor-agnostic session stack (bar, launcher, notifications,
# idle/lock, theming, utils, sunsetr) lives in the `session` aspect
# (modules/desktop/session.nix) — this aspect only owns the Niri session
# itself. Adds a SDDM session; desktop.nix pins the SDDM default to Plasma.
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
{ flake, ... }:

{
  flake.modules.nixos.niri.imports = [
    ./_core.nix
  ];
}
