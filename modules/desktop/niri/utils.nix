# Niri/Wayland session only — session utility binaries used by binds in
# config.kdl: screenshots, media/brightness keys, clipboard management,
# wallpaper application and picker.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Race-free wallpaper application: starts the awww daemon and waits for its
  # socket (no magic sleeps), then applies the default wallpaper.
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    awww-daemon &
    until awww query >/dev/null 2>&1; do sleep 0.25; done
    awww img /home/rykard/my-nixos-config/dotfiles/niri/wallpaper.png
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
        -config /home/rykard/my-nixos-config/dotfiles/niri/rofi/config.rasi \
        -p "Wallpaper" |
      sed 's/\x0icon.*$//' # rofi strips dmenu metadata; strip defensively
    )
    [ -n "$picked" ] && awww img "$picked"
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
  config = lib.mkIf config.features.desktop.niri.enable {
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
      thumbnailer
    ];
  };
}
