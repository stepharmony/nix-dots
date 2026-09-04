final: prev: {
  # Bitwig Studio, hard-pinned to 6.1 (nixpkgs already renames their attrs
  # per major version — this reconstruction is immune), with a theming jar
  # slot: drop a modified bitwig.jar at ~/.config/bitwig/bitwig.jar and the
  # launcher bind-mounts it over the stock jar. See pkgs/bitwig/ and TIPS.md.
  bitwig-studio = final.callPackage ../pkgs/bitwig/package.nix { };
}
