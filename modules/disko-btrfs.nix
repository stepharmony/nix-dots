# Shared disko layout — GPT with ESP + btrfs subvolumes, imported via core.nix.
# Override the target disk per host by setting `hostDisk` if a machine's drive
# differs from the default.
#
# This file owns every fileSystem of every host that imports it
# (hardware-configuration.nix defines none). Deploy a fresh install with, e.g.:
#   sudo nix run github:nix-community/disko -- --mode destroy,format,mount --flake .#manus
# WARNING: that command DESTROYS everything on the target disk.
{
  lib,
  config,
  ...
}:

{
  options.hostDisk = lib.mkOption {
    type = lib.types.str;
    default = "/dev/nvme0n1";
    description = "Disk that holds the NixOS install (ESP + btrfs via disko).";
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
}
