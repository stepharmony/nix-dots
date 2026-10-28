# Niri — scrollable-tiling Wayland compositor, the main desktop.
# The session stack it spawns (waybar, rofi, mako, swaylock/swayidle,
# utils, sunsetr) is installed by the `session` aspect
# (modules/desktop/session.nix) — this aspect only owns the Niri session
# itself, the default session in ly (desktop.nix).
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
{ flake, ... }:

{
  flake.modules.nixos.niri.imports = [
    ./_core.nix
  ];
}
