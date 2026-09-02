# pkgs

Custom package expressions, pulled in via `overlays/default.nix`.

- `pkgs/<name>/` — **active**: wired into the system through an overlay entry
- `pkgs/dormant/<name>/` — **reference only**: retired expressions kept as
  working templates (e.g. for pinning a package ahead of nixpkgs again).
  Not built, not imported; still kept syntactically valid by the formatter.
