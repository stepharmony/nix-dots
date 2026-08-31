{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.music.enable = lib.mkEnableOption "music production tools";

  config = lib.mkIf config.features.music.enable {
    # commented till i figure out wtf to do with this
    # in the meantime:
    # nix-shell -p steam-run --run "steam-run sh ableton-wine-setup-2026.07.29.1.run"
    #   programs.nix-ld.enable = true;
    #
    #   programs.nix-ld.libraries = with pkgs; [
    #     pipewire
    #     libjack2
    #     alsa-lib
    #   ];

    environment.systemPackages = with pkgs; [
      freetype
      cabextract
    ];
  };
}
