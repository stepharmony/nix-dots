# overlays

Nixpkgs overlays, applied to **all hosts** via `nixpkgs.overlays` in
`modules/common.nix`. `default.nix` composes them; the package expressions
they reference live in `../pkgs/`.

Current contents:

- **bitwig-studio** — hard-pinned 6.1 (reconstructed from the nixpkgs 6.x
  derivation; immune to upstream attr renames) plus a theming jar slot:
  drop a modified `bitwig.jar` at `~/.config/bitwig/bitwig.jar` and the
  launcher bind-mounts it over the stock jar at launch. See `../pkgs/bitwig/`.
- **skoll** — not in nixpkgs: video-to-picture sync CLAP for Bitwig plus its
  Skoll Transport extension, built from source
  ([liminalfield/skoll](https://github.com/liminalfield/skoll)). music.nix
  links both into `~/.clap` and `~/Bitwig Studio/Extensions`. Bump: change
  `version` + `src.hash`, set `cargoHash = lib.fakeHash;`, build once, paste
  the hash from the error. See `../pkgs/skoll/`.

The general pin/retire workflow (including the dormant reference in
`pkgs/dormant/`) is documented in TIPS.md "Custom packages & overlays".
