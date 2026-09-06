# Host aspect: manus — desktop (AMD CPU + NVIDIA GPU, 8G swap, no hibernation).
{ flake, ... }:

{
  flake.modules.nixos.host-manus =
    {
      inputs,
      flake,
      pkgs,
      username,
      ...
    }:
    {
      imports = [
        # Chaotic Nyx: wires the cachyos overlay + cache. Nothing consumes it
        # yet — kept for the planned endgame (cachyos kernel + nvidia_cachyos,
        # see TIPS.md "What will download vs. what will compile").
        inputs.chaotic.nixosModules.default

        flake.modules.nixos.common
        flake.modules.nixos.users
        flake.modules.nixos.disk
        flake.modules.nixos.pipewire
        flake.modules.nixos.desktop
        flake.modules.nixos.session
        flake.modules.nixos.niri
        flake.modules.nixos.specialisations
        flake.modules.nixos.xremap
        flake.modules.nixos.nvidia
        flake.modules.nixos.gaming
        flake.modules.nixos.music
        flake.modules.nixos.study
        flake.modules.nixos.dev
        flake.modules.nixos.winpodx
      ];

      networking.hostName = "manus"; # Define your hostname.

      # Set your time zone.
      time.timeZone = "Europe/Bucharest";

      # Latest kernel, matched with the latest NVIDIA open kernel module.
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Swapfile on the @swap subvolume (nodatacow); zswap is configured in
      # common.nix. No hibernation on this host on purpose: no
      # boot.resumeDevice is set. 8G is plenty for 16G RAM with zswap
      # compressing.
      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 8 * 1024; # MiB -> 8G
        }
      ];

      users.users.${username}.extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
}
