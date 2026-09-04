# Niri — scrollable-tiling Wayland compositor, alongside Plasma.
# This aspect owns the whole Niri session stack. It is Wayland/session
# specific — do not reuse these files from X11 or session-agnostic modules.
# Adds a SDDM session; desktop.nix pins the SDDM default to Plasma.
# Note: xremap sits below the compositor, so Niri binds see Graphite letters.
#
# Files prefixed with `_` are plain NixOS modules — import-tree skips them at
# the flake level (paths containing `/_`) and they are only pulled in here,
# as part of the `niri` aspect.
{ flake, ... }:

{
  flake.modules.nixos.niri.imports = [
    ./_core.nix
    ./_bar.nix
    ./_launcher.nix
    ./_notifications.nix
    ./_idle-lock.nix
    ./_theming.nix
    ./_utils.nix
    ./_sunsetr.nix
  ];
}
