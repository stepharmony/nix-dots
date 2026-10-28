# Compositor-agnostic Wayland session stack (Niri): the classic tools niri's
# upstream default config expects — waybar, fuzzel, mako, swaylock/swayidle —
# plus utils, the sunsetr blue-light filter and the tiling default apps
# (_apps.nix: kitty, Thunar, zathura, imv, xarchiver; also used by qtile, as
# the x11 boot inherits this). Everything here is only *installed*; niri's
# config.kdl spawns it, so none of it runs in Plasma.
# The `_`-prefixed modules are plain NixOS modules — import-tree skips them
# at the flake level (paths containing `/_`) and only this aspect pulls them in.
{ flake, ... }:

{
  flake.modules.nixos.session.imports = [
    ./session/_bar.nix
    ./session/_launcher.nix
    ./session/_notifications.nix
    ./session/_idle-lock.nix
    ./session/_utils.nix
    ./session/_sunsetr.nix
    ./session/_apps.nix
  ];
}
