{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.gaming.enable = lib.mkEnableOption "gaming tools";

  config = lib.mkIf config.features.gaming.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      prismlauncher
      protonplus
      faugus-launcher
      gpu-screen-recorder
      gpu-screen-recorder-ui
      gpu-screen-recorder-notification
    ];
  };
}
