final: prev: {
  # Bitwig Studio, hard-pinned to 6.1 (nixpkgs already renames their attrs
  # per major version — this reconstruction is immune), with a theming jar
  # slot: drop a modified bitwig.jar at ~/.config/bitwig/bitwig.jar and the
  # launcher bind-mounts it over the stock jar. See pkgs/bitwig/ and TIPS.md.
  bitwig-studio = final.callPackage ../pkgs/bitwig/package.nix { };

  # Skoll — video-to-picture sync CLAP + Bitwig extension, not in nixpkgs.
  # Built from source; deployed into ~/.clap etc. by music.nix. See pkgs/skoll/.
  skoll = final.callPackage ../pkgs/skoll/package.nix { };

  # Vencord 1.15.16 (nixpkgs: 1.15.11): Discord's 2026-11-04 rspack client
  # update breaks older Vencord ("i.A is not a constructor", stuck on the
  # loading screen). Drop once nixpkgs ships >= 1.15.16. Upstream now pins
  # @types/react itself, so nixpkgs' fix-deps.patch/postPatch are dropped.
  vencord = prev.vencord.overrideAttrs (
    finalAttrs: old: {
      version = "1.15.16";
      src = old.src.override {
        tag = "v${finalAttrs.version}";
        hash = "sha256-aUJubLJpyLAZWiOezqFxPY6oVPgWVPQpajFqrJvrO9U=";
      };
      patches = [ ];
      postPatch = "";
      pnpmDeps = old.pnpmDeps.overrideAttrs {
        inherit (finalAttrs) src patches postPatch;
        outputHash = "sha256-HS8uZNepvDefjrsG3buVLFCVv7sHvazcwdpcT3EQ/78=";
      };
    }
  );

  # Helium — Chromium-based browser, not in nixpkgs: the signed upstream
  # tarball, verified at build time. helium-update bumps it separately from
  # nixpkgs; each launch notifies when outdated. See pkgs/helium/.
  helium = final.callPackage ../pkgs/helium/package.nix { };
  helium-update = final.callPackage ../pkgs/helium/update.nix { };
}
