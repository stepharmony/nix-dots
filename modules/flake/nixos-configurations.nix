# Host instantiations. mkHost keeps the shape it had in flake.nix; the hosts/
# directory (NixOS modules) is intentionally untouched in this skeleton phase.
{ inputs, ... }:
let
  mkHost =
    {
      host,
      username,
      extraModules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit username; };
      modules = [
        inputs.disko.nixosModules.default
        (../../. + "/hosts/${host}/configuration.nix")
      ]
      ++ extraModules;
    };
in
{
  systems = [ "x86_64-linux" ];

  flake.nixosConfigurations = {
    manus = mkHost {
      host = "manus";
      username = "rykard";
      extraModules = [ inputs.chaotic.nixosModules.default ];
    };

    spectre = mkHost {
      host = "spectre";
      username = "rykard";
    };
  };
}
