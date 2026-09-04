# Host instantiations. Each host composes dendritic aspects (flake.modules.nixos.*).
# `flake` is passed as a specialArg so aspects can import one another — the
# self-reference is lazy and cycle-free. `username` stays a specialArg (used by
# common.nix, users.nix, xremap.nix); chaotic is imported per host below.
{ inputs, flake, ... }:
let
  username = "rykard";

  mkHost =
    { host, modules }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          flake
          username
          ;
      };
      modules = [
        inputs.disko.nixosModules.default
        inputs.hjem.nixosModules.default
        (../. + "/hosts/${host}/hardware-configuration.nix")
      ]
      ++ modules;
    };
in
{
  flake.nixosConfigurations = {
    manus = mkHost {
      host = "manus";
      modules = [ flake.modules.nixos.host-manus ];
    };

    spectre = mkHost {
      host = "spectre";
      modules = [ flake.modules.nixos.host-spectre ];
    };
  };
}
