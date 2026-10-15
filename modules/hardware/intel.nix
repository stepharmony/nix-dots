# Intel iGPU support (spectre laptop).
{ flake, ... }:

{
  flake.modules.nixos.intel =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          vpl-gpu-rt
          mesa-demos
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-media-driver
        ];
      };

      hardware.enableRedistributableFirmware = true;

      # VA-API hardware video acceleration for Intel
      # environment.systemPackages = with pkgs; [
      #   intel-media-driver
      # ];

      # Switch from older i915 drivers to xe
      boot.kernelParams = [
        "i915.force_probe=!7d55"
        "xe.force_probe=7d55"
      ];

      # Set the VA-API driver explicitly to
      # the modern Intel Media Driver
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      # Useful tools to check GPU status
      environment.systemPackages = with pkgs; [
        libva-utils      # run `vainfo` to check VA-API
        intel-gpu-tools  # run `sudo intel_gpu_top`
      ];
    };
}
