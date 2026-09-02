# DORMANT — reference copy of nixpkgs master's protonplus expression (0.6.5).
# Retired 2026-09: nixos-unstable caught up, so the overlay entry was disabled.
# Not built, not imported; kept as a working template for pinning packages
# ahead of nixpkgs. To re-enable: move back to pkgs/protonplus/package.nix and
# uncomment the overlay line in overlays/default.nix.
# (see TIPS.md "Custom packages & overlays" for the full workflow)
{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  wrapGAppsHook4,
  meson,
  ninja,
  pkg-config,
  vala,
  glib,
  glib-networking,
  gtk4,
  json-glib,
  libadwaita,
  libarchive,
  libgee,
  libsoup_3,
  sdl3,
  libnotify,
  appstream,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "protonplus";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "Vysp3r";
    repo = "protonplus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9KHtPG/gTtNjYCuStpb4tO3BiB09cSsTk7PpnX8o7qI=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    glib-networking
    gtk4
    json-glib
    libadwaita
    libarchive
    libgee
    libsoup_3
    sdl3
    libnotify
    appstream
  ];

  meta = {
    mainProgram = "protonplus";
    description = "Simple Wine and Proton-based compatibility tools manager";
    homepage = "https://github.com/Vysp3r/ProtonPlus";
    changelog = "https://github.com/Vysp3r/ProtonPlus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
