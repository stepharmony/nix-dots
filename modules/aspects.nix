# Declares the `flake.modules.nixos` aspect namespace. Without this option,
# flake-parts treats the `flake.modules` output as a unique value and refuses
# to merge the aspect definitions scattered across the tree (modules/*.nix).
# `deferredModule` values can be imported directly as NixOS modules — see
# modules/hosts.nix.
#
# Also exposes `flake` (= config.flake) as a module arg to every module in
# the tree, so aspects can reference each other (flake.modules.nixos.*).
{ lib, config, ... }:

{
  options.flake.modules.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    description = "NixOS module aspects, composed per host in modules/hosts/.";
    default = { };
  };

  config._module.args.flake = config.flake;
}
