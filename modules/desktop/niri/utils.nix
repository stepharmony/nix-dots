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
  # Race-free wallpaper application: starts the swww daemon and waits for its
  # socket (no magic sleeps), then applies the default wallpaper.
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    swww-daemon &
    until swww query >/dev/null 2>&1; do sleep 0.25; done
    swww img /home/rykard/my-nixos-config/dotfiles/niri/wallpaper.png
  '';

  # Wallpaper picker: rofi over ~/Pictures/Wallpapers, applies via swww.
  wallpaperPicker = pkgs.writeShellScriptBin "wallpaper-picker" ''
    wallpaper=$(
      find "$HOME/Pictures/Wallpapers" -type f \
        \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) |
      rofi -dmenu -config /home/rykard/my-nixos-config/dotfiles/niri/rofi/config.rasi -p "Wallpaper"
    )
    [ -n "$wallpaper" ] && swww img "$wallpaper"
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
      swww
      wallpaper
      wallpaperPicker
    ];
  };
}
