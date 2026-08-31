# overlays

Nixpkgs overlays, applied to **all hosts** via `nixpkgs.overlays` in
`modules/core.nix`. `default.nix` composes them; the package expressions they
reference live in `../pkgs/`.

Current contents:

- **protonplus** — pins 0.6.5 ahead of nixos-unstable (still 0.5.21).
  **Delete it once `nix eval nixpkgs#protonplus.version` reports >= 0.6.5**,
  otherwise it will silently shadow future nixpkgs updates.
