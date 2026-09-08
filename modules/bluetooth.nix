# Audio — always on, on both hosts.
{ flake, ... }:

{
  flake.modules.nixos.bluetooth =
    { pkgs, ... }:
    {
      # Bluetooth for NixOS
      # Simple for the time being, unless there a need
      # for more parameters/customizability
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true; # Shows battery charge for supported devices
          };
          Policy = {
            AutoEnable = true;   # Automatically turns on controllers when found
          };
        };
      };
    };
}
