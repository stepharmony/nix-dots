# Gaming tools (both hosts).
{ flake, ... }:

{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
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
