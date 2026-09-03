{
  description = "NixOS configuration for manus (desktop) and spectre (laptop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dendritic skeleton: flake-parts + auto-imported module tree (modules/flake).
    # When the NixOS modules graduate to flake.modules.nixos aspects, the tree
    # grows to cover all of ./modules.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules/flake);
}
