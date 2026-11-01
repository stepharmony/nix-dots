# Video editing (spectre). Kdenlive rather than DaVinci Resolve: Resolve's video
# timeline doesn't work on Intel iGPUs under Linux.
{ flake, ... }:

{
  flake.modules.nixos.editing =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        kdePackages.kdenlive
      ];
    };
}
