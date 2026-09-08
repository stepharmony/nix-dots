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
        powerOnBoot = false;
      };

      # Control media player using Bluetooth headset
      services.mpris-proxy.enable = true;
    };
}
