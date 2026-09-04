# Hyprland — third SDDM session (Plasma stays default), native scrolling
# layout (core since 0.55 — the Niri-style tape, no plugin).
# The compositor-agnostic session stack lives in the `session` aspect.
{ flake, ... }:

{
  flake.modules.nixos.hyprland.imports = [
    ./_core.nix
  ];
}
