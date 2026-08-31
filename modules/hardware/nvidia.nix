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
        # package = pkgs.nvidia_cachyos;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
    };

    boot.extraModprobeConfig = "options nvidia NVreg_PreserveVideoMemoryAllocations=1";
  };
}
