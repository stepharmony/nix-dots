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
        flake.modules.nixos.winpodx
      ];

      networking.hostName = "spectre";

      # Disk for disko (wipe/format target at install; the installed fstab
      # references partitions by-partuuid, so this never changes after).
      # Sanity-check on the machine before wiping: ls /dev/disk/by-id | grep SKHynix
      hostDisk = "/dev/disk/by-id/nvme-SKHynix_HFS001TEJ9X115N_AYCBN03291020BS3U";

      # Boot-menu / generation label (hostname-tagged; allowed chars
      # are [a-zA-Z0-9:_\.-]).
      system.nixos.label = "NixOS-spectre";

      # HiDPI: 3K panel — scale the Limine boot-menu font so it is readable
      # (Limine does not auto-detect DPI; ~"2x2" matches the CachyOS look).
      boot.loader.limine.style.graphicalTerminal.font.scale = "2x2";

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
