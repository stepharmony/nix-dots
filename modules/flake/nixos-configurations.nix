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
      # Chaotic Nyx: module wires the cachyos overlay + cache. Nothing consumes
      # it yet — it is kept for the planned endgame of switching both hosts to
      # the cachyos kernel and manus to nvidia_cachyos (see TIPS.md "What will
      # download vs. what will compile" for the cache-pairing gotcha).
      extraModules = [ inputs.chaotic.nixosModules.default ];
    };

    spectre = mkHost {
      host = "spectre";
      username = "rykard";
    };
  };
}
