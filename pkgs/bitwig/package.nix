# Bitwig Studio 6.1 — hard-pinned against nixpkgs updates (the 6.x attr was
# already renamed once upstream; this reconstruction is immune), with a
# runtime jar slot for theming: drop a modified bitwig.jar at
# ~/.config/bitwig/bitwig.jar and it is bubblewrap-bound over the stock jar
# at launch. Delete the file to return to the stock jar — no rebuilds either
# way. Modeled on nixpkgs' own bitwig-studio5.nix + bitwig-wrapper.nix.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  mktemp,
  bubblewrap,
  writeShellScript,
  alsa-lib,
  atk,
  cairo,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  lcms2,
  libglvnd,
  libjack2,
  libjpeg_turbo,
  nghttp2,
  libudev-zero,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxkbcommon,
  libxtst,
  pango,
  pipewire,
  vulkan-loader,
  xcb-imdkit,
  zlib,
}:
let
  version = "6.1";

  unwrapped = stdenv.mkDerivation {
    pname = "bitwig-studio-unwrapped";
    inherit version;

    src = fetchurl {
      name = "bitwig-studio-6.1.deb";
      url = "https://www.bitwig.com/dl/Bitwig%20Studio/6.1/installer_linux";
      hash = "sha256-dJbwn8JNHuSZ/lKQV4zoSbbthDdHl4J7hhmOZ5AdA2M=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3
      makeWrapper
    ];
    # we only want $gappsWrapperArgs here
    dontWrapGApps = true;

    buildInputs = [
      alsa-lib
      atk
      cairo
      freetype
      gdk-pixbuf
      glib
      gtk3
      harfbuzz
      lcms2
      libglvnd
      libjack2
      libjpeg_turbo
      nghttp2
      libudev-zero
      libx11
      libxcb
      libxcb-util
      libxcb-wm
      libxcursor
      libxkbcommon
      libxtst
      pango
      pipewire
      (lib.getLib stdenv.cc.cc)
      vulkan-loader
      xcb-imdkit
      zlib
    ];

    installPhase = ''
      runHook preInstall

      mkdir "$out"
      cp -r usr/share "$out"
      cp -r opt/bitwig-studio "$out"/libexec

      # Bitwig includes a copy of libxcb-imdkit.
      # Removing it will force it to use our version.
      rm -f "$out"/libexec/lib/bitwig-studio/libxcb-imdkit.so.1

      runHook postInstall
    '';

    postFixup = ''
      for e in "$out"/libexec/bin/*gtk*; do
        if [ -f "$e" ] && [ -x "$e" ]; then
          wrapProgram "$e" "''${gappsWrapperArgs[@]}"
        fi
      done
    '';

    meta = {
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  launcher = writeShellScript "bitwig-studio" ''
    set -e
    # Layout verified against the nixpkgs 6.1 build: the deb payload sits at
    # libexec/ (bin/, resources/, and the real entry point libexec/bitwig-studio).
    APP_DIR=${unwrapped}
    BWRAP=${bubblewrap}/bin/bwrap
    MKTEMP=${mktemp}/bin/mktemp

    # Jar slot: bind-mount the user's themed bitwig.jar over the stock one
    # inside the sandbox. The store copy is never touched; deleting the file
    # returns to stock on the next launch.
    CUSTOM_JAR="''${XDG_CONFIG_HOME:-$HOME/.config}/bitwig/bitwig.jar"
    STOCK_JAR="$APP_DIR"/libexec/bin/bitwig.jar
    BINDS=()
    if [ -f "$CUSTOM_JAR" ] && [ -f "$STOCK_JAR" ]; then
      BINDS+=(--bind "$CUSTOM_JAR" "$STOCK_JAR")
      echo "bitwig-studio: using custom jar $CUSTOM_JAR"
    fi

    # Writable Vamp resources, as in the nixpkgs launcher.
    TMPDIR=$($MKTEMP --directory)
    cp -r "$APP_DIR"/libexec/resources/VampTransforms "$TMPDIR"
    chmod -R u+w "$TMPDIR/VampTransforms"

    bwrap \
      --bind / / \
      --bind "$TMPDIR"/VampTransforms "$APP_DIR"/libexec/resources/VampTransforms \
      --dev-bind /dev /dev \
      "''${BINDS[@]}" \
      "$APP_DIR"/libexec/bitwig-studio \
      || true

    rm -rf "$TMPDIR"
  '';
in
stdenv.mkDerivation {
  pname = "bitwig-studio";
  inherit version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 ${launcher} $out/bin/bitwig-studio
    cp -r ${unwrapped}/share $out
  '';

  passthru = {
    inherit unwrapped version;
  };

  meta = {
    description = "Digital audio workstation";
    license = lib.licenses.unfree;
    mainProgram = "bitwig-studio";
    platforms = [ "x86_64-linux" ];
  };
}
