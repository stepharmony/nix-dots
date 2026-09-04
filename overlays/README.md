# overlays

Nixpkgs overlays, applied to **all hosts** via `nixpkgs.overlays` in
`modules/common.nix`. `default.nix` composes them; the package expressions
they reference live in `../pkgs/`.

Current contents:

- **bitwig-studio** — hard-pinned 6.1 (reconstructed from the nixpkgs 6.x
  derivation; immune to upstream attr renames) plus a theming jar slot:
  drop a modified `bitwig.jar` at `~/.config/bitwig/bitwig.jar` and the
  launcher bind-mounts it over the stock jar at launch. See `../pkgs/bitwig/`.

The general pin/retire workflow (including the dormant reference in
`pkgs/dormant/`) is documented in TIPS.md "Custom packages & overlays".
