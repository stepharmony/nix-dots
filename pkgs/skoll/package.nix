# Skoll — video sync for scoring to picture in Bitwig on Linux: a CLAP
# plugin whose window shows a video (drawn by mpv) that follows Bitwig's
# transport, plus the optional "Skoll Transport" controller extension that
# reports the playhead while Bitwig is stopped.
# https://github.com/liminalfield/skoll — no nixpkgs package; built from
# source here (upstream's scripts/install.sh + install-extension.sh, as Nix).
#
# Outputs:
#   $out/lib/clap/skoll.clap                        (CLAP only — upstream says
#     to prefer it: the VST3 build doesn't mark the project dirty on new video)
#   $out/share/bitwig/extensions/Skoll.bwextension
# Deployed into ~/.clap and ~/Bitwig Studio/Extensions by music.nix (hjem).
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  jdk21_headless,
}:

let
  # Bitwig's extension API jar, which upstream's install-extension.sh curls
  # on first run. API 25 = Bitwig 6.1.
  extensionApi = fetchurl {
    url = "https://maven.bitwig.com/com/bitwig/extension-api/25/extension-api-25.jar";
    hash = "sha256-hCsaBaGymxfERAyzYJwQKVPjoNKL6RDnQ7zmqio40bY=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skoll";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "liminalfield";
    repo = "skoll";
    tag = "v${finalAttrs.version}";
    hash = "sha256-af3PPA5TMIOxpGaCRn53pCfXBby39BdYeB76hRmzSLs=";
  };

  cargoHash = "sha256-VT3k8l8JNDwc1YUFv7UlnR00scaj4wBe/GcP/+NVu0Q=";

  nativeBuildInputs = [ jdk21_headless ];

  # `cargo build` builds the root package's cdylib (xtask is only a workspace
  # member, not a default one). That replaces `cargo xtask bundle`: on Linux a
  # CLAP bundle is just the .so renamed to .clap.
  cargoBuildFlags = [ "--lib" ];

  postBuild = ''
    # Skoll Transport extension — same steps as scripts/install-extension.sh.
    mkdir -p ext/classes
    javac --release 21 -d ext/classes -cp ${extensionApi} $(find extension/src -name '*.java')
    cp -r extension/META-INF ext/classes/
    jar --create --file ext/Skoll.bwextension -C ext/classes .
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 "$(find target -path '*/release/libskoll.so' | head -n1)" $out/lib/clap/skoll.clap
    install -Dm644 ext/Skoll.bwextension $out/share/bitwig/extensions/Skoll.bwextension
    runHook postInstall
  '';

  meta = {
    description = "Video sync for scoring to picture in Bitwig on Linux (CLAP + Bitwig extension)";
    homepage = "https://github.com/liminalfield/skoll";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
})
