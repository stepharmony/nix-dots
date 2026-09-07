# nix-dots

NixOS flake for two machines, both installed with [disko](https://github.com/nix-community/disko) onto btrfs:

| Flake ref | Machine | User | Hardware / key bits |
|---|---|---|---|
| `.#manus` | desktop | `rykard` | AMD + NVIDIA (open kernel module, latest driver), latest kernel, Plasma 6 (Wayland) + Niri sessions, PipeWire, chrony, 8G swapfile + zswap, **no hibernation** |
| `.#spectre` | laptop | `rykard` | Intel CPU + iGPU, Plasma 6 (Wayland) + Niri sessions, PipeWire, chrony, 32G swapfile + zswap, **hibernation enabled**, automatic timezone (geoclue2) |

Both disks are `/dev/nvme0n1` (confirmed).

## Repository layout

Dendritic setup: [flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree)
auto-import every file under `modules/`. Each file is a flake-parts module that
declares a NixOS **aspect** under `flake.modules.nixos.<name>`; each host
composes its aspects in `modules/hosts/`. [hjem](https://hjem.feel-co.org/)
manages `rykard`'s `$HOME`.

```
flake.nix                  # inputs (nixpkgs, chaotic, disko, hjem, flake-parts, import-tree)
                           # → mkFlake over import-tree ./modules
TIPS.md                    # tips & tricks (store forensics, overlays workflow, maintenance)
hosts/
  manus/                   # desktop: hardware-configuration.nix (disko owns fileSystems)
  spectre/                 # laptop: same
modules/
  aspects.nix              # declares the flake.modules.nixos namespace + `flake` module arg
  hosts.nix                # flake.nixosConfigurations — mkHost + both hosts
  hosts/manus.nix          # host aspect: composes aspects + host deltas (chaotic here)
  hosts/spectre.nix        # host aspect: hibernation, automatic-timezoned
  common.nix               # shared base: bootloader, zswap, Wayland env, chrony, nh,
                           # locales, fstrim, nix settings, user apps
  users.nix                # the rykard user + hjem $HOME management (dotfile deployment)
  disk.nix                 # shared disko layout (ESP + btrfs subvolumes), hostDisk option
  pipewire.nix             # audio, always on
  gaming.nix  music.nix    # imported by both host aspects
  hardware/nvidia.nix      # desktop GPU aspect
  hardware/intel.nix       # laptop iGPU aspect
  xremap.nix               # Graphite remapping (system daemon + per-session bridge)
   desktop.nix              # Plasma 6 — the default SDDM session on both hosts
    desktop/session.nix      # compositor-agnostic Wayland stack (bar packages,
                            # launcher, notifications, idle/lock, utils,
                            # sunsetr; gruvbox theming parked — see session.nix)
   desktop/niri/            # niri aspect: default.nix + _core.nix (satellite pin)
   formatter.nix            # nix fmt wrapper (perSystem)
   systems.nix              # systems = [ x86_64-linux ]
overlays/                  # packages pinned ahead of nixpkgs; wired via common.nix
pkgs/                      # custom package expressions used by overlays (see TIPS.md)
dotfiles/                  # sources deployed into $HOME by hjem: niri config.kdl +
                           # rice (rofi, swayidle/swaylock, sunsetr — each lands in
                           # its default ~/.config location),
                           # quickshell/island (custom gruvbox dynamic island —
                           # spawned as `qs -c island`, Mod+N = notification center),
                           # matugen (wallpaper -> Material You palette -> island);
                           # xremap system service config (deployed to /etc by xremap.nix)
```

Disk layout (both hosts): GPT on `/dev/nvme0n1` — 1G ESP at `/boot`, then btrfs with subvolumes
`@root` → `/`, `@home` → `/home`, `@nix` → `/nix`, `@log` → `/var/log`, `@swap` → `/swap` (nodatacow, holds the swapfile).
All btrfs mounts use `noatime,compress=zstd`; TRIM runs weekly via `fstrim` (no `discard` mount option).

## Daily usage

The config expects the repo to live at `/home/rykard/nix-dots` (that is what `nh` is pointed at).

```bash
nh os switch          # rebuild + switch; host is auto-detected from the hostname
nix fmt               # format all nix files
nix flake update      # bump nixpkgs + chaotic + disko
```

`nh` is optional; the equivalent is `sudo nixos-rebuild switch --flake .#manus` (or `.#spectre`).

## Installing NixOS with disko

> ⚠️ **WARNING**: disko's `destroy` mode **erases the entire target disk**.
> Triple-check that you are targeting the machine/disk you intend to wipe, and that any data you care about is backed up first.

### Pre-flight checklist

- [ ] `modules/disk.nix` points at the right disk — currently `/dev/nvme0n1` for **both** hosts (confirmed). Change it if a machine's drive differs.
- [ ] Swap sizes: manus has 8G (fine for 16G RAM, no hibernation), spectre has 32G (required for full hibernation with 32G RAM).
- [ ] **The repo is a git repository.** Push it to a private remote so the installer can clone it:
  ```bash
  git remote add origin <your-remote-url> && git push -u origin main
  ```
  No remote? Copy it with `scp -r` or a USB stick instead.
- [ ] Working internet on the target machine (nixpkgs, chaotic and the system closure are downloaded during install).

### 1. Boot the installer

1. Download the **NixOS minimal ISO** (x86_64) from <https://nixos.org/download> and flash it to a USB stick.
2. Boot the target machine from the USB stick.
3. Get network:
   - Ethernet: usually automatic (DHCP).
   - Wi-Fi: `sudo -i`, then `wpa_cli` → `add_network` / `set_network ...` / `enable_network`, or use `nmcli` if present.
4. `sudo -i` to get a root shell.

### 2. Get this repo onto the installer

```bash
# preferred (after git init + push, see pre-flight):
git clone <your-remote-url> /root/nix-dots
cd /root/nix-dots

# or from another machine on the LAN:
#   scp -r /home/manus/nix-dots root@<installer-ip>:/root/nix-dots

# or from a USB stick:
#   mount /dev/sdX1 /mnt && cp -r /mnt/nix-dots /root/ && umount /mnt
```

The location during install does not matter; after first boot the repo must end up at
`/home/rykard/nix-dots` (see post-install).

### 3. Partition, format and mount with disko

```bash
# desktop:
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode destroy,format,mount --flake .#manus

# laptop:
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode destroy,format,mount --flake .#spectre
```

What this does: reads the host's disko layout from the flake, wipes `/dev/nvme0n1`, creates the GPT
layout (ESP + btrfs subvolumes), formats it, and mounts everything under `/mnt`.

Verify afterwards:

```bash
findmnt -t btrfs   # should show @root on /mnt plus @home, @nix, @log, @swap
findmnt /boot      # should show the vfat ESP
```

### 4. Install the system

```bash
sudo nixos-install --flake .#manus    # or .#spectre
```

This evaluates the full configuration, downloads/builds the closure onto `/mnt`, installs the
bootloader, and finally prompts for a **root password**.

> Alternative one-liner (disko + install in one command):
> ```bash
> sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko#disko-install -- --flake .#manus
> ```

### 5. Set the user password (before rebooting!)

While still in the installer — where the keyboard is plain QWERTY — set
`rykard`'s password by chrooting into the freshly installed system:

```bash
sudo nixos-enter # chroot into the system nixos-install just prepared
passwd rykard
exit
```

Why here: inside the graphical session xremap remaps to Graphite, but the
console TTYs and the SDDM greeter stay **QWERTY** — xremap only runs inside a
logged-in session. Setting the password in the ISO means never having to type
it blind on a TTY, and the QWERTY TTYs match plain muscle memory anyway.

Then:

```bash
reboot
```

1. Remove the USB stick. Boot into NixOS (Limine boot menu — first boot
   shows the current generation; pick it and the firmware falls through to
   the Limine entry).
2. Log in directly as **rykard** with the password just set — no root login needed.
3. Forgot to set it? Boot, log in as root with the step-4 password, run
   `passwd rykard` — the console TTY is plain QWERTY (xremap only remaps
   inside the graphical session).
4. (Optional hardening, later: lock the root password with `sudo passwd -l root`
   once you are sure `rykard` + sudo work.)

### 6. Post-install checklist

**Both hosts:**

- [ ] Put the repo where `nh` expects it:
  ```bash
  # git clone <your-remote-url> /home/rykard/nix-dots
  # then fix ownership:
  chown -R rykard:users /home/rykard/nix-dots
  ```
- [ ] Log in as `rykard` and verify daily usage works:
  ```bash
  cd /home/rykard/nix-dots && nh os switch
  ```
- [ ] btrfs subvolumes mounted: `findmnt -t btrfs`
- [ ] zswap active: `cat /sys/module/zswap/parameters/{enabled,compressor,zpool}` → expect `Y`, `zstd`, `zsmalloc`
- [ ] Swap active: `swapon --show` (manus: 8G, spectre: 32G)
- [ ] Time sync + timezone: `timedatectl` (NTP service should show chronyd; on spectre the
      timezone is managed by automatic-timezoned, see `systemctl status automatic-timezoned`)
- [ ] Weekly TRIM timer: `systemctl status fstrim.timer`
- [ ] xremap active with the Graphite layout: `systemctl status xremap` (system daemon)
      and `systemctl --user status xremap-bridge` (session bridge; TTYs and SDDM stay
      QWERTY by design)
- [ ] Both SDDM sessions present: Plasma (default) and Niri —
      niri config lives at `~/.config/niri/config.kdl` (hjem-managed store
      symlink; source in `dotfiles/niri/`). The Niri session spawns the
      quickshell island + the rice stack, all reading their default
      `~/.config` locations — nothing depends on the repo path.
- [ ] hjem deployed the rice: `ls -l ~/.config/niri/config.kdl ~/.config/rofi`
      should show store symlinks
- [ ] `nix fmt` and `nix flake check` work from the repo

**manus (desktop) only:**

- NVIDIA driver (open kernel module, latest) should be loaded: `lsmod | grep nvidia`
- Plasma (Wayland) session is available from SDDM

**spectre (laptop) only:**

- Test hibernation: `systemctl hibernate` → power off → press power button → session should resume.
  The resume offset comes from `boot.resumeDevice = "/swap/swapfile"` and systemd initrd.
- `hosts/spectre/hardware-configuration.nix` is a **generic placeholder**. If any hardware misbehaves
  (Wi-Fi, touchpad, sensors), run `sudo nixos-generate-config` on the laptop and merge the
  `boot.initrd.*` / `hardware.*` bits from the generated file into the placeholder — **do not** let it
  re-add `fileSystems` (disko owns those).

## Troubleshooting

- **`experimental Nix feature 'nix-command' is disabled` on the ISO** — the commands above already
  pass `--extra-experimental-features 'nix-command flakes'`; if you type other flake commands, add
  the same flag or `export NIX_CONFIG="experimental-features = nix-command flakes"` first.
- **disko errors about an existing filesystem** — that is expected on a disk that has data on it;
  the `destroy,format,mount` mode is the one that wipes it. Make sure you really want that.
- **Wrong disk name** (`nvme1n1` etc.) — check with `lsblk`, then set `hostDisk` in the host
  configuration (default is `/dev/nvme0n1` in `modules/disk.nix`) **before** running disko.
- **Chaotic Nyx download issues during install** — chaotic substituters are enabled by its module
  (imported only on manus); a flaky network during `nixos-install` is the usual culprit — just rerun.
- **`nh os switch` says the flake path is wrong** — the repo must be at `/home/rykard/nix-dots`.
