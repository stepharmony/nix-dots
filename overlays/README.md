# overlays

Nixpkgs overlays, applied to **all hosts** via `nixpkgs.overlays` in
`modules/core.nix`. `default.nix` composes them; the package expressions they
reference live in `../pkgs/`.

Current contents: **no active pins** — `default.nix` is comment-only, kept as
the reference for how to wire a pinned package (its last entry, protonplus,
was retired to `pkgs/dormant/` once nixpkgs caught up).
