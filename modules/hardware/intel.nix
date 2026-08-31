# Intel iGPU module.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.hardware.intel.enable = lib.mkEnableOption "Intel iGPU support";

  config = lib.mkIf config.features.hardware.intel.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.enableRedistributableFirmware = true;

    # VA-API hardware video acceleration for Intel
    environment.systemPackages = with pkgs; [
      intel-media-driver
    ];
  };
}
