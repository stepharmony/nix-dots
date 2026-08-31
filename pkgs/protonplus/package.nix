# Copy of nixpkgs master's expression, pinning protonplus ahead of
# nixos-unstable (which still ships 0.5.21).
#
# DELETE ME once nixos-unstable ships >= 0.6.5 — check with:
#   nix eval nixpkgs#protonplus.version
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
