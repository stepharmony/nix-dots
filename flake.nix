{
  description = "NixOS configuration for manus (desktop) and spectre (laptop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dendritic: flake-parts + auto-imported module tree. Every file under
    # ./modules is a flake-parts module; NixOS config lives in aspects under
    # flake.modules.nixos.*, composed per host in modules/hosts/. Files whose
    # path contains `/_` are plain NixOS modules excluded from the tree
    # (used by aspects, e.g. modules/desktop/niri/_*.nix).
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
