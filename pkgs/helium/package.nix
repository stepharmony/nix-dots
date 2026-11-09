# Helium — Chromium-based browser (https://helium.computer/), not in
# nixpkgs. Repackages the signed upstream x86_64 tarball the way nixpkgs'
# google-chrome repackages its .deb. The build checks the tarball's OpenPGP
# signature against the vendored pubkey.asc (fingerprint
# BE67 7C19 89D3 5EAB 2C5F 26C9 3516 01AD 01D6 378E, from the helium-linux
# repo and README; expires 2028-10-10) and fails without a good one.
#
# Updates are separate from nixpkgs: `helium-update` (update.nix) writes the
# newest verified release into source.json, then `nh os switch`. Every
# launch asks GitHub in the background and notifies only when outdated.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  patchelf,
  bintools,
  gnupg,
  writeShellScript,
  curl,
  libnotify,
  coreutils,
  xdg-utils,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  addDriverRunpath,
  # Linked or dlopened at runtime (google-chrome's list).
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  bzip2,
  cairo,
  cups,
  dbus,
  expat,
  flac,
  fontconfig,
  freetype,
  gcc-unwrapped,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  harfbuzz,
  icu,
  libcap,
  libdrm,
  libexif,
  libglvnd,
  libkrb5,
  libopus,
  libpng,
  libpulseaudio,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  libgbm,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  snappy,
  systemdLibs,
  vulkan-loader,
  wayland,
}:
let
  source = lib.importJSON ./source.json;
  inherit (source) version;

  url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
  signature = fetchurl {
    url = "${url}.asc";
    hash = source.signatureHash;
  };

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    cups
    dbus
    expat
    flac
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    gtk3
    gtk4
    harfbuzz
    icu
    libcap
    libdrm
    libexif
    libglvnd
    libkrb5
    libopus
    libpng
    libpulseaudio
    libva
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libgbm
    nspr
    nss
    pango
    pciutils
    pipewire
    snappy
    systemdLibs
    vulkan-loader
    wayland
  ];
  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;

  # The releases/latest redirect names the newest published release without
  # the GitHub API (no rate limit). Silent when offline, current, or when
  # the latest tag sorts older (a pulled release).
  checkUpdate = writeShellScript "helium-check-update" ''
    latest=$(${lib.getExe curl} -fsS --max-time 5 -o /dev/null -w '%{redirect_url}' \
      https://github.com/imputnet/helium-linux/releases/latest) || exit 0
    latest=''${latest##*/}
    [[ -n $latest && $latest != "${version}" ]] || exit 0
    newest=$(printf '%s\n' "${version}" "$latest" | ${coreutils}/bin/sort -V | ${coreutils}/bin/tail -n1)
    [[ $newest == "$latest" ]] || exit 0
    ${lib.getExe libnotify} -a Helium -i helium "Helium $latest available" \
      "Installed: ${version}. Run helium-update, then nh os switch."
  '';
in
stdenvNoCC.mkDerivation {
  pname = "helium";
  inherit version;

  src = fetchurl {
    inherit url;
    inherit (source) hash;
  };

  nativeBuildInputs = [
    gnupg
    makeWrapper
    patchelf
  ];
  # Setup hooks fill XDG_ICON_DIRS and GSETTINGS_SCHEMAS_PATH for the wrapper.
  buildInputs = [
    adwaita-icon-theme
    glib
    gtk3
    gtk4
    gsettings-desktop-schemas
  ];

  preUnpack = ''
    export GNUPGHOME=$(mktemp -d)
    gpg --batch --quiet --dearmor -o "$GNUPGHOME/helium.gpg" < ${./pubkey.asc}
    gpgv --keyring "$GNUPGHOME/helium.gpg" ${signature} "$src"
  '';

  installPhase = ''
    runHook preInstall

    app=$out/share/helium
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -a . $app

    # GTK UI only (the Qt shims want Qt5/Qt6); the nix wrapper replaces
    # helium-wrapper; the system vulkan-loader replaces the bundled one.
    rm $app/{libqt5_shim.so,libqt6_shim.so,helium-wrapper,chromedriver}
    ln -sf ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $app/libvulkan.so.1

    for elf in $app/{helium,helium_crashpad_handler}; do
      patchelf --set-interpreter ${bintools.dynamicLinker} --set-rpath ${rpath} $elf
    done
    for so in $app/*.so; do
      patchelf --set-rpath ${rpath} $so
    done

    # Chromium's own "outdated" bubble is off; checkUpdate replaces it.
    makeWrapper $app/helium $out/bin/helium \
      --run "${checkUpdate} &" \
      --prefix LD_LIBRARY_PATH : ${rpath} \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:${addDriverRunpath.driverLink}/share" \
      --set CHROME_WRAPPER helium \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags "--simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'"

    mv $app/helium.desktop $out/share/applications/helium.desktop
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-quiet 'Exec=helium' "Exec=$out/bin/helium"
    mv $app/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

    runHook postInstall
  '';

  dontPatchELF = true;
  dontStrip = true;

  meta = {
    description = "Chromium-based web browser";
    homepage = "https://helium.computer/";
    license = lib.licenses.gpl3Only;
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
