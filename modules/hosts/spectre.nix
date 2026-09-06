# Host aspect: spectre — laptop (Intel CPU + iGPU, 32G swap, hibernation).
{ flake, ... }:

{
  flake.modules.nixos.host-spectre =
    {
      flake,
      pkgs,
      username,
      lib,
      ...
    }:
    {
      imports = [
        flake.modules.nixos.common
        flake.modules.nixos.users
        flake.modules.nixos.disk
        flake.modules.nixos.pipewire
        flake.modules.nixos.desktop
        flake.modules.nixos.session
        flake.modules.nixos.niri
        flake.modules.nixos.specialisations
        flake.modules.nixos.xremap
        flake.modules.nixos.intel
        flake.modules.nixos.gaming
        flake.modules.nixos.music
        flake.modules.nixos.study
        flake.modules.nixos.dev
      ];

      networking.hostName = "spectre";

      # Match the desktop kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Timezone default until automatic-timezoned overrides it via geoclue2.
      time.timeZone = lib.mkDefault "Europe/Bucharest";
      services.automatic-timezoned.enable = true;

      # Swapfile on the @swap subvolume (nodatacow); zswap is configured in
      # common.nix. Hibernation: boot.initrd.systemd (from common.nix) +
      # resumeDevice let the initrd auto-detect the swapfile offset. 32G
      # swap >= 32G RAM, so a full hibernation fits.
      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 32 * 1024; # MiB -> 32G
        }
      ];

      boot.resumeDevice = "/swap/swapfile";

      users.users.${username}.extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
}
