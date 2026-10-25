# Music production tools (both hosts).
{ flake, ... }:

{
  flake.modules.nixos.music =
    {
      pkgs,
      lib,
      username,
      ...
    }:
    {
      # Skoll (pkgs/skoll, via overlay): links the CLAP and the Skoll Transport
      # extension into the folders Bitwig scans, next to the manually
      # installed plugins there (hjem only manages these two files). Then in
      # Bitwig: Settings → Controllers → Add Controller → Liminal Field →
      # Skoll Transport.
      # The config pins mpv and the file dialog by store path: Skoll launches
      # them from inside Bitwig's FHS env, so PATH lookups are avoided.
      hjem.users.${username} = {
        files = {
          ".clap/skoll.clap".source = "${pkgs.skoll}/lib/clap/skoll.clap";
          "Bitwig Studio/Extensions/Skoll.bwextension".source =
            "${pkgs.skoll}/share/bitwig/extensions/Skoll.bwextension";
        };
        xdg.config.files."skoll/config.toml".text = ''
          mpv_path = "${lib.getExe pkgs.mpv}"
          file_dialog = ["${lib.getExe pkgs.kdePackages.kdialog}", "--title", "Open Video", "--getopenfilename", "/home/${username}"]
        '';
      };

      environment.systemPackages = with pkgs; [
        # Bitwig Studio 6.1, hard-pinned (see overlays/default.nix + TIPS.md).
        # Theming: drop a modified bitwig.jar at ~/.config/bitwig/bitwig.jar —
        # the launcher bind-mounts it over the stock jar at launch.
        bitwig-studio
        reaper # 7.82 — DAW (unfree, covered by the global allowUnfree;
        # evaluation nag until licensed)
        musescore # 4.7.5 — notation
        mpv # video player; Skoll draws through it (also handy on its own)
        ffmpeg # Skoll proxies: intra-frame MJPEG/ProRes so scrubbing keeps up
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
