# Niri — scrollable-tiling Wayland compositor, alongside Plasma.
# The session stack it spawns (waybar, rofi, mako, swaylock/swayidle,
# utils, sunsetr) is installed by the `session` aspect
# (modules/desktop/session.nix) — this aspect only owns the Niri session
# itself. Adds a SDDM session; desktop.nix pins the SDDM default to Plasma.
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
{ flake, ... }:

{
  flake.modules.nixos.niri.imports = [
    ./_core.nix
  ];
}
