# Bluetooth — imported by spectre only.
{ flake, ... }:

{
  flake.modules.nixos.bluetooth =
    { pkgs, ... }:
    {
      # Pairing UI + tray applet (spawned by niri's config.kdl and qtile's
      # autostart; both skip it on hosts without bluetooth).
      services.blueman.enable = true;

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
            AutoEnable = true; # Automatically turns on controllers when found
          };
        };
      };
    };
}
