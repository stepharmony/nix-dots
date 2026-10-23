# STM32 — preliminary notes

> **Status: preliminary.** Written before the course published its toolchain
> instructions. Nothing here is wired into the config yet — once the course
> names its IDE/tools, turn the draft below into `modules/embedded.nix`,
> adjust it, and trim this file down to whatever stays useful.

STM32 chips are ARM Cortex-M microcontrollers. Most dev boards (Nucleo,
Discovery) carry an on-board **ST-Link** debugger: one USB cable powers the
board, flashes it, debugs it, and exposes a serial console. Whatever IDE the
course picks, it sits on top of the same layers:

| Layer | Job | nixpkgs package | Version (2026-10) |
|---|---|---|---|
| Cross-compiler | build ARM binaries (`arm-none-eabi-gcc`, `-gdb`, `-objcopy`, `-size`) | `gcc-arm-embedded` | 15.3.rel2 |
| Flasher / debug server | talk to the ST-Link, flash, gdb server | `openocd` | 0.12.0 |
| Flasher (lightweight) | `st-flash`, `st-info --probe` | `stlink` | 1.8.0 |
| Flasher (modern alt.) | `probe-rs`, `cargo-flash` style, also C | `probe-rs-tools` | 0.32.0 |
| UART bootloader flasher | flash over serial, no ST-Link | `stm32flash` | 0.7 |
| Pin/clock config + code gen | ST's graphical project generator | `stm32cubemx` | 6.18.1 (unfree, not cached) |
| Build system alt. | board-agnostic projects | `platformio` | 6.2.0 |

All of these are cached on cache.nixos.org except `stm32cubemx`.
**STM32CubeIDE** and **STM32CubeProgrammer** are *not* in nixpkgs.

## The NixOS-specific bit: USB permissions

Without udev rules the ST-Link only works as root. All three flashers ship
rules, and `services.udev.packages` installs them from both
`<pkg>/lib/udev/rules.d` and `<pkg>/etc/udev/rules.d`:

- `stlink` — `49-stlinkv{1,2,2-1,3}.rules`, `MODE:="0666"` (anyone).
- `openocd` — `60-openocd.rules`, `TAG+="uaccess"` (logged-in user gets
  access; the `plugdev` group it also names doesn't need to exist).
- `probe-rs-tools` — `69-probe-rs.rules`.

The **serial console** (ST-Link virtual COM port, `/dev/ttyACM*`) is a
separate thing: it needs the `dialout` group, which `rykard` isn't in yet
(current groups: `networkmanager wheel xremap-rykard kvm`). Group changes
need a re-login.

## Draft aspect (not imported anywhere)

```nix
# Embedded / STM32 tools (both hosts). ARM Cortex-M cross toolchain +
# ST-Link flashing/debugging, with udev rules so no sudo is needed.
{ flake, ... }:

{
  flake.modules.nixos.embedded =
    { pkgs, username, ... }:
    {
      environment.systemPackages = with pkgs; [
        gcc-arm-embedded # arm-none-eabi-gcc/gdb/objcopy/size
        openocd # gdb server + flashing over ST-Link
        stlink # st-flash, st-info --probe
      ];

      # ST-Link USB access for the logged-in user (rules ship in the packages)
      services.udev.packages = with pkgs; [
        openocd
        stlink
      ];

      # /dev/ttyACM* — the board's serial console via the ST-Link VCP
      users.users.${username}.extraGroups = [ "dialout" ];
    };
}
```

Then add `flake.modules.nixos.embedded` to both `modules/hosts/*.nix`, next
to `dev` and `hdl`. `username` is a specialArg from `modules/hosts.nix`, so
it's available in every NixOS module.

## Smoke test once the board is in hand

```bash
st-info --probe                        # ST-Link found? prints chip ID + flash size
openocd -f interface/stlink.cfg -f target/stm32f4x.cfg   # swap target/ for the actual family
arm-none-eabi-gcc --version
ls -l /dev/ttyACM*                     # serial console present, group dialout
```

The `target/*.cfg` file depends on the chip family (`stm32f0x`, `stm32f4x`,
`stm32l4x`, `stm32g4x`, …) — read it off the chip or board name.

## What the course choice changes

| If the course uses… | Then on NixOS |
|---|---|
| **Makefiles / CMake + arm-none-eabi** | The draft above is the whole setup. |
| **PlatformIO** | Add `platformio`; it downloads its own toolchains into `~/.platformio`, which may need `steam-run`/FHS for the prebuilt binaries. Keep the udev rules. |
| **STM32CubeMX** (code gen only) | Add `stm32cubemx` (unfree — fine, `allowUnfree` is global; not cached, builds/repacks locally). Build the generated Makefile/CMake project with the draft toolchain. |
| **STM32CubeIDE** | Not in nixpkgs. Options: ST's Linux installer inside an FHS env / `steam-run`, distrobox, or CubeMX + helix/clangd instead. Decide once it's confirmed. |
| **Keil µVision / IAR** | Windows-only → winpodx. USB passthrough of the ST-Link into the pod is the open question. |

## Editor side (helix)

Helix's C support from `dev.nix` (clangd) works for STM32 projects once
clangd knows the cross target: generate `compile_commands.json` (CMake:
`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; Makefiles: `bear -- make`) and add a
`.clangd` with `--target=arm-none-eabi` if headers don't resolve.

## Open questions for the course

- Which board / chip family?
- Which IDE or build system is mandatory (vs. just recommended)?
- HAL, LL, or bare-metal register access?
- Are submissions built in a specific environment (e.g. a CubeIDE project)?
