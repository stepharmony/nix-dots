{
  config,
  lib,
  ...
}:

{
  options.features.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";

  config = lib.mkIf config.features.hardware.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      nvidia = {
        open = true;
        modesetting.enable = true;
        powerManagement.enable = true;
        # Endgame (not yet activated): pair this driver with the cachyos kernel
        # on both hosts so everything comes from Chaotic's cache instead of
        # compiling — see TIPS.md "What will download vs. what will compile".
        # package = pkgs.nvidia_cachyos;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
    };

    boot.extraModprobeConfig = "options nvidia NVreg_PreserveVideoMemoryAllocations=1";
  };
}
