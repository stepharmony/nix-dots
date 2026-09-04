# Compositor-agnostic Wayland session stack (Niri):
# bar, launcher, notifications, idle/lock, theming, utils, blue-light filter.
# The `_`-prefixed modules are plain NixOS modules — import-tree skips them
# at the flake level (paths containing `/_`) and only this aspect pulls them in.
{ flake, ... }:

{
  flake.modules.nixos.session.imports = [
    ./session/_bar.nix
    ./session/_launcher.nix
    ./session/_notifications.nix
    ./session/_idle-lock.nix
    ./session/_theming.nix
    ./session/_utils.nix
    ./session/_sunsetr.nix
  ];
}
