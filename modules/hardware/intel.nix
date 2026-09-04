# Intel iGPU support (spectre laptop).
{ flake, ... }:

{
  flake.modules.nixos.intel =
    { pkgs, ... }:
    {
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
