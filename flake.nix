{
  description = "NixOS configuration for manus (desktop) and spectre (laptop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      chaotic,
      disko,
      ...
    }:
    let
      mkHost =
        {
          host,
          username,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit username; };
          modules = [
            disko.nixosModules.default
            ./hosts/${host}/configuration.nix
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations.manus = mkHost {
        host = "manus";
        username = "rykard";
        extraModules = [ chaotic.nixosModules.default ];
      };

      nixosConfigurations.spectre = mkHost {
        host = "spectre";
        username = "rykard";
      };

      # plain nixfmt over every .nix file in the repo — the treewide
      # nixfmt-tree wrapper wandered far outside the repo, so wrap manually
      formatter.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.writeShellScriptBin "formatter" ''
          exec ${pkgs.nixfmt}/bin/nixfmt $(
            git ls-files '*.nix' 2>/dev/null ||
              find . -name '*.nix' -not -path './.git/*'
          )
        '';
    };
}
