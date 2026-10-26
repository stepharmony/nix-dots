# Shared base for every host. Hosts opt into further aspects (pipewire,
# desktop, niri, gaming, ...) in modules/hosts/.
{ flake, inputs, ... }:

{
  flake.modules.nixos.common =
    { username, pkgs, ... }:
    {
      # Bootloader.
      boot.loader = {
        efi.canTouchEfiVariables = true;
        limine = {
          enable = true;
          # Keep the boot menu tidy: cap listed generations (limine submenus
          # group each generation + its specialisations).
          maxGenerations = 20;
        };
      };

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
      networking.networkmanager.plugins = with pkgs; [
        networkmanager-openconnect
      ];

      # Electron/ozone apps run Wayland-native in every graphical session
      # (Plasma and Niri alike).
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # GSettings/dconf daemon — GTK apps persist settings through it in every
      # session. (Session-specific dconf defaults live in their aspects, e.g.
      # session/_theming.nix; keeping the daemon here is infrastructure only.)
      programs.dconf.enable = true;

      # chrony replaces systemd-timesyncd (module forces timesyncd off itself).
      # Defaults: NixOS pool servers, makestep, RTC drift tracking, NM online/offline dispatch.
      services.chrony.enable = true;

      # overlays/ pins packages ahead of nixpkgs (see overlays/README.md)
      nixpkgs.overlays = [
        (import ../overlays)
        inputs.millennium.overlays.default
      ];

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
        flake = "/home/${username}/nix-dots"; # sets NH_OS_FLAKE variable for you
      };

      environment.systemPackages = with pkgs; [
        fastfetch
        tree
        micro
        steam-run
        kdePackages.kate
        # Under niri, Discord runs through XWayland: natively on Wayland it
        # comes up hugely oversized at spectre's fractional 1.75 scale (window
        # flips between over- and undersized; --disable-features=
        # WaylandFractionalScaleV1 doesn't help). NIRI_SOCKET only exists in
        # niri sessions, so Plasma keeps native Wayland. The flag lands after
        # the inner wrapper's --ozone-platform=wayland, and the last one wins.
        (symlinkJoin {
          name = "discord-niri-x11";
          paths = [
            (discord.override {
              # OpenASAR is behaving strangely, removed
              # until further notice
              # withOpenASAR = true;
              withVencord = true;
            })
          ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            for b in discord Discord; do
              wrapProgram $out/bin/$b --add-flags "\''${NIRI_SOCKET:+--ozone-platform=x11}"
            done
          '';
        })
        floorp-bin
        firefox
        brave-origin
        unrar
        google-chrome
        git
        gh
        ripgrep
        libqalculate
        btop
        rustdesk-flutter
        libreoffice-stable
        anydesk
        yt-dlp
        easyeffects
        qpdf
        qbittorrent
        openconnect
      ];

      services.udisks2.enable = true;
      services.mullvad-vpn.enable = true;
      services.mullvad-vpn.gui.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      system.stateVersion = "26.05";
    };
}
