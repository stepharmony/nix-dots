{
  pkgs,
  username,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/core.nix
  ];

  networking.hostName = "manus"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Latest kernel, matched with the latest NVIDIA open kernel module.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swapfile on the @swap subvolume (nodatacow); zswap is configured in core.nix.
  # No hibernation on this host on purpose: no boot.resumeDevice is set.
  # 8G is plenty for 16G RAM with zswap compressing.
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024; # MiB -> 8G
    }
  ];

  # Feature modules (imported in core.nix, enabled here).
  features.gaming.enable = true;
  features.music.enable = true;
  features.hardware.nvidia.enable = true;
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
