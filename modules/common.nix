# Shared base for every host. Hosts opt into further aspects (pipewire,
# desktop, niri, gaming, ...) in modules/hosts/.
{ flake, ... }:

{
  flake.modules.nixos.common =
    { username, pkgs, ... }:
    {
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # systemd initrd (lets the laptop auto-detect the hibernation swapfile offset)
      boot.initrd.systemd.enable = true;

      # zswap — shared by both hosts, both use a swapfile.
      # Verify after boot: cat /sys/module/zswap/parameters/{enabled,compressor,zpool}
      boot.kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=zstd" # efficient and modern
        "zswap.zpool=zsmalloc" # standard allocator
        "zswap.max_pool_percent=20"
      ];

      # Enable networking
      networking.networkmanager.enable = true;

      # Electron/ozone apps run Wayland-native in every graphical session
      # (Plasma and Niri alike).
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # chrony replaces systemd-timesyncd (module forces timesyncd off itself).
      # Defaults: NixOS pool servers, makestep, RTC drift tracking, NM online/offline dispatch.
      services.chrony.enable = true;

      # overlays/ pins packages ahead of nixpkgs (see overlays/README.md)
      nixpkgs.overlays = [ (import ../overlays) ];

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # hardlink identical files in the store
        auto-optimise-store = true;
        # start GC when free space drops below min, delete until above max
        min-free = 10 * 1024 * 1024 * 1024; # 10G
        max-free = 50 * 1024 * 1024 * 1024; # 50G
      };

      # weekly TRIM — btrfs mounts use noatime, never discard
      services.fstrim.enable = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "ro_RO.UTF-8";
        LC_IDENTIFICATION = "ro_RO.UTF-8";
        LC_MEASUREMENT = "ro_RO.UTF-8";
        LC_MONETARY = "ro_RO.UTF-8";
        LC_NAME = "ro_RO.UTF-8";
        LC_NUMERIC = "ro_RO.UTF-8";
        LC_PAPER = "ro_RO.UTF-8";
        LC_TELEPHONE = "ro_RO.UTF-8";
        LC_TIME = "ro_RO.UTF-8";
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/${username}/my-nixos-config"; # sets NH_OS_FLAKE variable for you
      };

      environment.systemPackages = with pkgs; [
        fastfetch
        tree
        micro
        steam-run
        opencode
        kdePackages.kate
        (discord.override {
          # OpenASAR is behaving strangely, removed
          # until further notice
          # withOpenASAR = true;
          withVencord = true;
        })
        floorp-bin
        brave-origin
        unrar
        google-chrome
        git
        btop
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      system.stateVersion = "26.05";
    };
}
