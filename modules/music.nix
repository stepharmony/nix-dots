# Music production tools (both hosts).
{ flake, ... }:

{
  flake.modules.nixos.music =
    { pkgs, ... }:
    {
      # Bitwig Studio 6.1, hard-pinned (see overlays/default.nix + TIPS.md).
      # Theming: drop a modified bitwig.jar at ~/.config/bitwig/bitwig.jar —
      # the launcher bind-mounts it over the stock jar at launch.
      environment.systemPackages = with pkgs; [
        bitwig-studio
        freetype
        cabextract
      ];

      # nix-ld lets prebuilt dynamically-linked binaries run directly: the
      # u-he install.sh license dialogs are plain gtk3/glib ELFs (the VST
      # .so payloads themselves need nothing here — they load inside
      # Bitwig's FHS env at runtime). If a dialog still complains, its
      # printed `ldd` output names the missing package — add it below.
      # Fallback for anything nix-ld chokes on:
      #   nix-shell -p steam-run --run "steam-run sh <installer>"
      #   e.g. the parked ableton-wine-setup idea
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        gtk3
        glib
        pango
        cairo
        gdk-pixbuf
        atk
        harfbuzz
        fribidi
        libepoxy
        libxkbcommon
        wayland
        libX11
        libXext
        libXrandr
        libXi
        libXcursor
        libXcomposite
        libXdamage
        libXfixes
        libXinerama
        dbus
        fontconfig
        freetype
      ];
    };
}
