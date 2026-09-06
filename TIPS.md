# Tips & Tricks

A grab-bag of Nix/NixOS commands that come in handy day to day with this
config. Most examples assume you are in `/home/rykard/my-nixos-config`.

## What will download vs. what will compile

Before a rebuild, check what the new closure actually needs. Anything not
available on a substituter (`cache.nixos.org`, Chaotic's cache) gets compiled
locally.

```bash
# dry-run the build: shows "this derivation will be built" (compile)
# vs "these N paths will be copied" (download)
nixos-rebuild dry-build --flake .#manus

# same idea, whole host closure from this flake
nix build --dry-run .#nixosConfigurations.manus.config.system.build.toplevel
```

Why `nvidia_cachyos` (Chaotic Nyx) can trigger needless compiling: the NVIDIA
driver must exist in Chaotic's cache for the *exact kernel build* you pair it
with. `nvidiaPackages.latest` built against nixpkgs `linuxPackages_latest`
rarely matches their cache — pairing Chaotic's own `linuxPackages_cachyos`
kernel with `nvidia_cachyos` is what makes everything substitute.

## Store forensics

```bash
# total closure size of the running system
nix path-info -Sh /run/current-system

# biggest things in the closure (top 25)
nix path-info -rSh /run/current-system | sort -k2 -h | tail -25

# why does package X exist in my closure? (prints the dependency chain)
nix why-depends /run/current-system "$(nix eval --raw nixpkgs#mesa)"

# what changed between the running system and a freshly built ./result
nix store diff-closures /run/current-system ./result
```

## Nix store maintenance

```bash
# one-time sweep: hardlink all duplicate store paths
# (auto-optimise-store only covers paths added after it was enabled)
nix-store --optimise

# see real per-filetype compression ratios on the btrfs store
sudo nix run nixpkgs#compsize -- /nix
```

Auto-GC is configured via `min-free`/`max-free` in common.nix: the daemon starts
GC when free space on `/nix` drops below 10G and deletes until it exceeds 50G —
a safety net between scheduled `nh clean` runs. `compress-force=zstd` on the
`@nix` subvolume was considered and skipped: the heuristic already compresses
the compressible majority, forcing it costs CPU on every rebuild for
single-digit gains.

## Custom packages & overlays

The `overlays/` and `pkgs/` directories exist for pinning a package ahead of
nixpkgs. `modules/common.nix` applies them to every host:

```nix
nixpkgs.overlays = [ (import ../overlays) ];
```

`overlays/default.nix` composes all overlays; each overlay pulls a custom
expression from `pkgs/<name>/package.nix` via `final.callPackage`. Any
reference to that package (e.g. `protonplus` in gaming.nix) then resolves to
the pinned version, on both hosts.

**Recipe — bump a package ahead of nixpkgs:**

1. Check whether nixpkgs master already packages the version:
   `https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/<x>/<name>/package.nix`
2. Copy that expression into `pkgs/<name>/package.nix` (drop the
   `nix-update-script` passthru — it only makes sense inside nixpkgs).
3. If master hasn't packaged it yet, copy the unstable expression and bump
   `version` + `src.hash` yourself.
4. If the hash doesn't verify, set `hash = lib.fakeHash;` temporarily, build
   once, and take the correct hash from the error output.
5. Wire it up in `overlays/default.nix` and verify:
   ```bash
   nix eval .#nixosConfigurations.manus.pkgs.<name>.version   # want the new version
   nix eval .#nixosConfigurations.spectre.pkgs.<name>.version
   ```

**Is the overlay still needed?** Compare the channel against your pin:

```bash
nix eval nixpkgs#protonplus.version        # what nixos-unstable ships
nix eval .#nixosConfigurations.manus.pkgs.protonplus.version  # what you pin
```

Once the channel reports a version >= your pin, the overlay is redundant.

**How to delete one:**

1. Remove the entry from `overlays/default.nix` (or the whole overlay file if
   it was the only one). Move `pkgs/<name>/` to `pkgs/dormant/<name>/` if the
   expression is worth keeping as a reference (the formatter keeps it valid),
   or delete it outright if not.
2. `nh os switch` — the nixpkgs version takes over again.
3. Leaving a stale overlay in place is harmless at first but will silently
   shadow future nixpkgs updates, so don't forget this step.

## Everyday loop

```bash
nh os switch                # rebuild + switch, host auto-detected from hostname
nix fmt                     # format all nix files
nix flake update            # bump all inputs (nixpkgs, chaotic, disko)
nix flake update nixpkgs    # bump just one input
nix flake check             # evaluate everything, catch errors early
```

## One-off tools without polluting the config

```bash
nix shell nixpkgs#nixfmt -c nixfmt --check modules/common.nix
nix run nixpkgs#hello
```

## Specialisations (Wayland / X11 boot entries)

The default boot is the Wayland system; `wayland` and `x11` appear as
systemd-boot sub-entries after a switch. Each specialization writes its name
to `/etc/specialisation`, which **nh ≥ 4.4 reads**: from inside a
specialization, `nh os switch` activates *that* specialization (and diffs it
against itself) instead of bouncing you to the base system. Without the
marker file, nh does the base — the gotcha this prevents:

```bash
# inside the x11 boot: rebuild + activate the x11 specialization in place
nh os switch

# manual equivalent (if the marker is ever missing):
sudo /nix/var/nix/profiles/system/specialisation/x11/bin/switch-to-configuration switch
```

To make x11 the *persistent* default instead of a boot entry, flip the host
aspect (import `x11` instead of `desktop` + `niri` in `modules/hosts/*.nix`).

## Generations and rollback

```bash
# list system generations
nix-env --list-generations --profile /nix/var/nix/profiles/system

# roll back (old generations are also selectable from the systemd-boot menu)
sudo nixos-rebuild test --rollback    # switch back now, new gen stays default
sudo nixos-rebuild switch --rollback  # switch back AND make it the default

# garbage collection (nh clean already runs on a schedule; full manual clean:)
nix-collect-garbage -d
```

## Testing without touching the running system

```bash
# build but don't activate
nixos-rebuild build --flake .#manus

# evaluate only — catches merge conflicts and typos fast, builds nothing
nix eval .#nixosConfigurations.manus.config.system.build.toplevel.drvPath

# arbitrary config queries — great for "does host X have Y enabled?"
nix eval .#nixosConfigurations.spectre.config.programs.steam.enable
nix eval .#nixosConfigurations.spectre.config.boot.kernelPackages.kernel.version

# build a bootable VM of a host to test without touching real hardware
nixos-rebuild build-vm --flake .#manus
```

## Machine-specific checks

### Time (chrony / automatic-timezoned)

```bash
timedatectl              # NTP service should show chronyd; current timezone
chronyc tracking         # offset, drift, which server is being used
chronyc sources -v       # all configured servers and their reach/state
systemctl status automatic-timezoned   # spectre only: geoclue2 timezone daemon
journalctl -u automatic-timezoned -u geoclue   # spectre only: why geolocation failed
```

### Swap / zswap / hibernation

```bash
swapon --show                                              # manus: 8G, spectre: 32G
cat /sys/module/zswap/parameters/{enabled,compressor,zpool} # expect Y, zstd, zsmalloc
cat /sys/power/state                                       # spectre must list "disk"
systemctl hibernate                                        # spectre only
```

### xremap (Graphite layout, graphical session only)

Two units, official multi-DE architecture:

```bash
systemctl status xremap               # system daemon (dedicated `xremap` user)
systemctl --user status xremap-bridge # per-session bridge (kde/niri variant, auto-picked)
journalctl -u xremap -f               # daemon log
journalctl --user -u xremap-bridge -f # bridge log; "active window: class:" lines
```

If either fails, keys pass through unremapped (QWERTY) — nothing breaks.
Heads-up from the first activation: adding groups to an already-running
session requires a **full reboot**, not just re-login.

### Graphite ⇄ QWERTY toggle (Alt+Esc)

`Alt+Esc` flips the whole machine between Graphite and QWERTY via xremap's
native `set_mode` (two mode-scoped keymap blocks in
`dotfiles/xremap/graphite.yml`). It executes in-process — instant, no
daemon restart — and because the daemon is system-wide it works in every
graphical session **and on TTYs**. Games-to-QWERTY stays app-gated
independently: in QWERTY mode everything is QWERTY anyway, and the graphite
punctuation remaps sleep with the rest.

- Reset: every boot / daemon restart re-seeds Graphite (mode state lives
  only in the daemon) — a friend's session can't outlive a reboot.
- Chord customization: change `Alt-KEY_ESC` in **both** `to-qwerty` and
  `to-graphite` blocks. The chord is swallowed at evdev level, so no DE
  window-cycle binding can collide with it.
- Upstream quirk (why the toggle is `set_mode`, not a script): in the
  socket-variant daemon, the `launch` action matches but the queued command
  is never executed. Traced with `RUST_LOG=debug` (2026-09-05) — worth
  filing against https://github.com/xremap/xremap/issues.
- Future layout work (adaptive swaps, SFB fixes) is sketched in
  `dotfiles/xremap/IDEAS.md` — feasible with xremap's nested remaps whenever
  Graphite's actual weaknesses are known.

### Remap specific apps (games) to QWERTY

Already wired in `dotfiles/xremap/graphite.yml`: a `shared: games: &games`
list, an app-gated QWERTY identity modmap (first block — xremap uses the first
matching definition), and the shifted-punctuation keymap excluded via
`not: *games`. Making another app QWERTY is a four-step loop:

**1. Detect** — tail the live log, focus the app you care about, read the
`class` field (the `caption` is the window title, `class` is what you match on):

```bash
journalctl --user -u xremap-bridge -f | grep "active window"
# active window: caption: 'Momentum Mod - DX11', class: 'steam_app_1802710'
```

**2. Decide** — real-world casebook from the config's first week:

| class | verdict | why |
|---|---|---|
| `steam_app_1802710` | add (already covered) | Steam game window |
| `steam_app_default` | add (already covered) | umu/faugus game with unset `GAMEID` — the regex catches it too |
| `steam` | **don't** | the Steam client itself — you type in it, keep Graphite |
| `faugus-launcher` | **don't** | launcher GUI, same reasoning |
| `zenity` | **don't blanket-add** | generic dialog toolkit; protonfixes uses it but so does half the desktop |
| `steam_proton` | **don't** (yet) | empty-caption launch-transition shells, nothing to type |

Rule of thumb: revert *game windows*, keep *anything you read or type in*.

**3. Add** — exact names or `/regex/` in `dotfiles/xremap/graphite.yml`:

```yaml
shared:
  games: &games
    - /steam_app_/
    - /umu_/
    - Cyberpunk2077.exe
```

(YAML anchors must live under `shared:` — xremap rejects unknown top-level
fields.)

**4. Apply + verify** — `systemctl --user restart xremap` (or let the switch
trigger do it), refocus the app, type-test, and confirm the journal shows the
class as expected.

Optional quality-of-life: wire a reload combo so YAML tweaks don't need a
restart at all:

```yaml
keymap:
  - remap:
      F9: { action: reload }
```


## Known upstream issues

### Steam dropdown menus close instantly under Niri

xwayland-satellite 0.8.2's popup handling regressed: Steam menus (Friends,
right-click, top bar) close within ~0.3s under Niri. Worked around by a
**confirmed pin to satellite 0.8.1** in `modules/desktop/niri/default.nix`
(verified 2026-09-03). Games are unaffected; Steam client works fully on
Plasma (kwin's embedded Xwayland has no such issue).

Removal procedure: when nixpkgs ships a fixed satellite release, revert the
pin to plain `pkgs.xwayland-satellite`, switch, and test Steam dropdowns in a
Niri session before deleting the pin comment. Track:
- https://github.com/Supreeeme/xwayland-satellite/issues/468
- the satellite rewrite (issue #373) — the real fix

## Finding things in nixpkgs

```bash
nix search nixpkgs <name>          # search packages
nix eval nixpkgs#floorp-bin.version # check a package's version in your pinned nixpkgs
```
