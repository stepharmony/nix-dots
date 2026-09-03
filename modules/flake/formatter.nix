# nix fmt over every tracked .nix file in the repo.
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      formatter =
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellScriptBin "formatter" ''
          exec ${pkgs.nixfmt}/bin/nixfmt $(
            git ls-files '*.nix' 2>/dev/null ||
              find . -name '*.nix' -not -path './.git/*'
          )
        '';
    };
}
