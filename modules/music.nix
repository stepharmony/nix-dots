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
    let
      # skoll-proxy <video> — prepares a video for scoring with Skoll. Writes,
      # next to the original:
      #   <name>-proxy.mkv  intra-frame MJPEG (every frame a keyframe, so
      #                     scrubbing keeps up), longer side ≤ 1280 px (never
      #                     upscaled), any aspect ratio, burned-in timecode
      #                     HH:MM:SS:FF at the video's own frame rate + a
      #                     second line with seconds and frame number
      #   <name>.wav        the audio, aligned to the video's first frame
      #                     (container start delays padded/trimmed), so it
      #                     goes at the same song position as Skoll's Offset
      # Frame rate: r_frame_rate, falling back to avg_frame_rate for
      # variable-frame-rate (phone) footage, which is made constant. NTSC
      # rates (29.97/59.94) get drop-frame timecode so it tracks the clock.
      skollProxy = pkgs.writeShellApplication {
        name = "skoll-proxy";
        runtimeInputs = with pkgs; [
          ffmpeg
          gawk
        ];
        text = ''
          if [[ $# -ne 1 || ! -f $1 ]]; then
            echo "usage: skoll-proxy <video>" >&2
            exit 1
          fi
          in=$1
          base=''${in%.*}
          proxy="$base-proxy.mkv"
          wav="$base.wav"
          for f in "$proxy" "$wav"; do
            if [[ -e $f ]]; then
              echo "skoll-proxy: $f already exists — not overwriting" >&2
              exit 1
            fi
          done

          # probe <stream> <field>: first value, or empty if there is no such stream
          probe() {
            ffprobe -v error -select_streams "$1" -show_entries "stream=$2" \
              -of default=noprint_wrappers=1:nokey=1 "$in" | head -n1
          }
          # ratio <a/b>: decimal value, 0 for a zero denominator
          ratio() { awk -v r="$1" 'BEGIN { split(r, a, "/"); print (a[2] + 0 ? a[1] / a[2] : 0) }'; }

          rate=$(probe v:0 r_frame_rate)
          if [[ -z $rate ]]; then
            echo "skoll-proxy: no video stream in $in" >&2
            exit 1
          fi
          if awk -v f="$(ratio "$rate")" 'BEGIN { exit !(f <= 0 || f > 120) }'; then
            rate=$(probe v:0 avg_frame_rate)
          fi
          fps=$(ratio "$rate")

          sep='\:'
          case $rate in 30000/1001 | 60000/1001) sep='\;' ;; esac

          # Text sizes and margins follow the proxy's shorter side.
          font="font=monospace:fontcolor=white:box=1:boxcolor=black@0.6:x=(w-tw)/2"
          tc="drawtext=$font:fontsize='min(w,h)/16':boxborderw=8:y='h-th-min(w,h)/32':timecode='00\:00\:00''${sep}00':rate=$rate"
          clock="drawtext=$font:fontsize='min(w,h)/27':boxborderw=6:y='h-th-min(w,h)*0.13':text='%{pts\:hms}   frame %{n}'"
          scale="scale=w='min(1280,iw)':h='min(1280,ih)':force_original_aspect_ratio=decrease:force_divisible_by=2,setsar=1"

          echo "skoll-proxy: $in — $rate fps ($fps)"
          ffmpeg -hide_banner -loglevel warning -stats -i "$in" -map 0:v:0 -an \
            -vf "setpts=PTS-STARTPTS,fps=$rate,$scale,$tc,$clock" \
            -c:v mjpeg -q:v 5 -pix_fmt yuv420p -color_range pc "$proxy"

          astart=$(probe a:0 start_time)
          if [[ -z $astart ]]; then
            echo "skoll-proxy: no audio stream — wrote only $proxy"
            exit 0
          fi
          vstart=$(probe v:0 start_time)
          # Align the WAV to the video's first frame: delay > 0 means the audio
          # starts later (pad silence), < 0 earlier (trim).
          delay=$(awk -v a="$astart" -v v="$vstart" 'BEGIN { printf "%.6f", (a == "N/A" ? 0 : a) - (v == "N/A" ? 0 : v) }')
          align=$(awk -v d="$delay" 'BEGIN {
            if (d > 0.0005) printf "adelay=%d:all=1", d * 1000 + 0.5
            else if (d < -0.0005) printf "atrim=start=%f,asetpts=PTS-STARTPTS", -d
            else print "anull"
          }')
          # Lossless sources keep 24 bits; lossy ones (AAC, Opus, ...) need no more than 16.
          codec=pcm_s16le
          case $(probe a:0 codec_name) in pcm_* | flac | alac | wavpack | truehd) codec=pcm_s24le ;; esac

          ffmpeg -hide_banner -loglevel warning -i "$in" -map 0:a:0 -vn -af "$align" -c:a "$codec" "$wav"

          echo "skoll-proxy: wrote $proxy and $wav (audio offset vs. video: ''${delay}s, compensated)"
        '';
      };
    in
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
          file_dialog = ["${lib.getExe pkgs.zenity}", "--file-selection", "--title=Open Video", "--filename=/home/${username}/"]
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
        skollProxy # skoll-proxy <video>: proxy + timecode + aligned WAV (see above)
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
