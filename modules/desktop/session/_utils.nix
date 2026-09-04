# Wayland session stack (Niri + Hyprland) — session utility binaries used by
# binds in config.kdl / hyprland.lua: screenshots, media/brightness keys,
# clipboard management, wallpaper application and picker, session exit.
{ pkgs, ... }:

let
  # Race-free wallpaper application: starts the awww daemon (unless one is
  # already running) and waits for its socket (no magic sleeps), then applies
  # the default wallpaper (baked-in store path of the repo file).
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon &
    until awww query >/dev/null 2>&1; do sleep 0.25; done
    awww img ${../../../dotfiles/niri/wallpaper.png}
  '';

  # Hibernate, guarded: manus has no hibernation support (no resumeDevice),
  # spectre does. Check /sys/power/state at click time so the shared power
  # menu stays honest on both hosts.
  hibernate = pkgs.writeShellScriptBin "hibernate" ''
    if grep -q disk /sys/power/state; then
      exec systemctl hibernate
    fi
    notify-send "Hibernate" "Hibernation is not supported on this host"
  '';

  # Wallpaper picker: rofi over ~/Pictures/Wallpapers with image previews.
  # Entries carry \0icon\x1fthumbnail:// icons (rofi dmenu protocol) which
  # rofi renders via the XDG thumbnailer installed below (cached in
  # ~/.cache/thumbnails, shared with Dolphin).
  wallpaperPicker = pkgs.writeShellScriptBin "wallpaper-picker" ''
    picked=$(
      find "$HOME/Pictures/Wallpapers" -type f \
        \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) |
      while read -r f; do printf '%s\0icon\x1fthumbnail://%s\n' "$f" "$f"; done |
      rofi -dmenu -show-icons \
        -p "Wallpaper" |
      sed 's/\x0icon.*$//' # rofi strips dmenu metadata; strip defensively
    )
    [ -n "$picked" ] && awww img "$picked"
  '';

  # Session exit for the shared power menu: niri and Hyprland quit
  # differently — pick from the session environment.
  wmExit = pkgs.writeShellScriptBin "wm-exit" ''
    if [ -n "$NIRI_SOCKET" ]; then
      exec niri msg action quit
    fi
    exec hyprctl dispatch exit
  '';

  # XDG thumbnailer so rofi can generate image previews. NixOS ships none;
  # the profile share dir is on $XDG_DATA_DIRS, which rofi scans.
  thumbnailer = pkgs.writeTextDir "share/thumbnailers/gdk-pixbuf.thumbnailer" ''
    [Thumbnailer Entry]
    TryExec=gdk-pixbuf-thumbnailer
    Exec=gdk-pixbuf-thumbnailer -s %s %u %o
    MimeType=image/png;image/jpeg;image/webp;image/bmp;image/gif;
  '';
in
{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    playerctl
    brightnessctl
    cliphist
    wl-clipboard
    awww
    gdk-pixbuf # provides gdk-pixbuf-thumbnailer on PATH
    wallpaper
    wallpaperPicker
    hibernate
    wmExit
    thumbnailer
  ];
}
