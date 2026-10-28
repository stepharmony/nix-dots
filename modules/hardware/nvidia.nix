# NVIDIA GPU support (manus desktop).
{ flake, ... }:

{
  flake.modules.nixos.nvidia =
    { config, ... }:
    {
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

      # niri on NVIDIA: the driver's free-buffer pool otherwise keeps ~1 GB
      # of VRAM in the compositor (niri wiki, "Nvidia"). Matches the process
      # name, so it only affects niri.
      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
        builtins.toJSON {
          rules = [
            {
              pattern = {
                feature = "procname";
                matches = "niri";
              };
              profile = "Limit Free Buffer Pool On Wayland Compositors";
            }
          ];
          profiles = [
            {
              name = "Limit Free Buffer Pool On Wayland Compositors";
              settings = [
                {
                  key = "GLVidHeapReuseRatio";
                  value = 0;
                }
              ];
            }
          ];
        };
    };
}
