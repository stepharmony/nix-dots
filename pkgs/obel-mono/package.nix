# Obel Mono 1.000 — monospaced typeface from Typographic Systems, not in
# nixpkgs. https://typographic.systems/obel-mono/ (SIL OFL 1.1, OFL.txt).
# The variable TTFs (roman + italic, wght 100-900) are vendored in fonts/:
# the release zip has no stable URL to fetch. Opt-in features: ss01 masking,
# ss02 handwritten, cv01 dotted zero, cv02-cv14 alternates.
{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "obel-mono";
  version = "1.000";

  src = ./fonts;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/share/fonts/truetype *.ttf
    install -Dm444 ${./OFL.txt} $out/share/licenses/obel-mono/OFL.txt
    runHook postInstall
  '';

  meta = {
    description = "Monospaced typeface for terminals and code";
    homepage = "https://typographic.systems/obel-mono/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
