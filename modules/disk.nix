# Shared disko layout — GPT with ESP + btrfs subvolumes, imported via the
# `disk` aspect. Each host pins `hostDisk` (a /dev/disk/by-id path) in
# modules/hosts/*.nix — by-id survives enumeration changes, and a wrong value
# fails loudly at disko time instead of wiping the wrong disk.
#
# This aspect owns every fileSystem of every host that imports it
# (hardware-configuration.nix defines none). Deploy a fresh install with, e.g.:
#   sudo nix run github:nix-community/disko -- --mode destroy,format,mount --flake .#manus
# WARNING: that command DESTROYS everything on the target disk.
{ flake, ... }:

{
  flake.modules.nixos.disk =
    {
      lib,
      config,
      ...
    }:

    {
      options.hostDisk = lib.mkOption {
        type = lib.types.str;
        description = ''
          Disk that holds the NixOS install (ESP + btrfs via disko), pinned per
          host as a /dev/disk/by-id path. Only the wipe/format step uses it —
          disko generates the installed fstab with by-partuuid references, so
          the value never changes after install. No default: the wipe target
          must be explicit.
        '';
      };

      config.disko.devices = {
        disk.main = {
          type = "disk";
          device = config.hostDisk;
          content = {
            type = "gpt";
            partitions = {
              esp = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # overwrite any existing filesystem
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      # nodatacow is required for a swapfile on btrfs
                      mountOptions = [
                        "noatime"
                        "nodatacow"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
