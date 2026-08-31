{ config, pkgs, ... }:
{
  imports = [
    ./xorg.nix
  ];

  services.xserver.windowManager.qtile = {
    enable = true;
    #     extraPackages = python3Packages: with python3Packages; [
    #       qtile-extras
    #     ];
  };
}
