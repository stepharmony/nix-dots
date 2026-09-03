{
  pkgs,
  username,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
  ];

  networking.hostName = "spectre";

  # Match the desktop kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Timezone default until automatic-timezoned overrides it via geoclue2.
  time.timeZone = lib.mkDefault "Europe/Bucharest";
  services.automatic-timezoned.enable = true;

  # Swapfile on the @swap subvolume (nodatacow); zswap is configured in core.nix.
  # Hibernation: boot.initrd.systemd (from core.nix) + resumeDevice let the
  # initrd auto-detect the swapfile offset. 32G swap >= 32G RAM, so a full
  # hibernation fits.
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024; # MiB -> 32G
    }
  ];

  boot.resumeDevice = "/swap/swapfile";

  # Feature modules (imported in core.nix, enabled here).
  features.gaming.enable = true;
  features.music.enable = true;
  features.hardware.intel.enable = true;
  features.desktop.niri.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
