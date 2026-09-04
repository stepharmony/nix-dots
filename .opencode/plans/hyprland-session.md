# Hyprland third-session plan — ready to execute

## Status

Execution was approved and started (Commit 1 restructure), then file-modification
tools (`edit`/`write`) got denied by permission rules mid-way. The half-done
`git mv` restructure was reverted; the repo is clean at `ba4b25c`
("Docs: reflect dendritic + hjem layout"). Everything below is researched and
verified — execution can resume the moment file edits are allowed again.

## Verified environment facts

- Pinned nixpkgs ships **Hyprland 0.56.2** — scrolling layout is **in core**
  since 0.55 (that's why `hyprlandPlugins.hyprscroller` throws a removal error
  and `hyprscrolling` no longer exists). **No plugin needed.**
- Since 0.55 the config language is **Lua** (`~/.config/hypr/hyprland.lua`);
  hyprlang `.conf` is deprecated. Docs live at
  `content/configuring/...` in `github:hyprwm/hyprland-wiki` (raw fetch works).
- `programs.hyprland.enable` currently false; adding it gives the SDDM session
  + `xdg-desktop-portal-hyprland`.
- `pkgs.xremap.passthru.hyprland` exists (xremap-hyprland-0.15.12).
- Entire rice (ironbar, rofi, swaync, swayidle/swaylock, sunsetr, awww,
  cliphist, grim/slurp, polkit-agent, thumbnailer) is compositor-agnostic.

## Lua API cheat-sheet (from the 0.56 wiki, raw sources saved in /tmp/opencode/wiki-*.md)

- Config: `hl.config({ input = { ... }, general = { ... }, cursor = { ... }, scrolling = { ... } })`
  — multiple calls merge; later same-option calls shadow.
- Monitors: `hl.monitor({ output = "DP-3", mode = "1920x1080@239.964", position = "0x0", scale = 1 })`
- Binds: `hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("firefox"))` — keys joined `" + "`.
- Autostart: `hl.on("hyprland.start", function() hl.exec_cmd("ironbar") end)` (or `hl.exec_cmd("a & b")`).
- Dispatchers (must go through `hl.dispatch(...)` inside functions):
  - `hl.dsp.exec_cmd(cmd)`, `hl.dsp.exit()` (prefer `hyprshutdown`), `hl.dsp.layout("msg")`
  - `hl.dsp.focus({ direction = "l" })` / `{ workspace = "2" }` / `{ monitor = "..." }`
  - `hl.dsp.window.close()`, `.float()`, `.fullscreen({ action = "toggle", mode = "fullscreen", layout_aware = true })`
  - `hl.dsp.window.move({ direction = "l" })`, `.move({ workspace = "2", follow = false })`, `.move({ monitor = "..." })`
  - `hl.dsp.dpms({ action = "disable" })` — NOT directly in binds; wrap in
    `hl.timer(..., { timeout = 500, type = "oneshot" })` per wiki warning.
- Scrolling config (namespace `scrolling`): `fullscreen_on_one_column` (default true),
  `column_width` 0.5, `focus_fit_method` 0 center / 1 fit, `follow_focus` true,
  `follow_min_visible` 0.4, `explicit_column_widths "0.333, 0.5, 0.667, 1.0"`,
  `wrap_focus` true, `wrap_swapcol` true, `direction "right"`.
- Layout messages (`hl.dsp.layout("...")`): `move ±col/±px`, `colresize 0.5|+0.2|-0.2|+conf|-conf|all N`,
  `fit active|visible|all|toend|tobeg|expand`, `fit_into_view`, `focus <dir>`,
  `promote`, `swapcol l|r`, `inhibit_scroll`, `expel`, `consume`, `consume_or_expel prev|next`.
- Window rule: `hl.window_rule({ name = "...", match = { class = "..." }, float = true, scrolling_width = 0.5 })`
- General: `layout = "scrolling"`, `gaps_in/out`, `border_size`, `col = { active_border = ..., inactive_border = ... }`.
- Input: `accel_profile = "flat"`, `kb_options = "compose:ralt"`, `repeat_delay = 250`, `repeat_rate = 25`, `follow_mouse = 1`.
- Cursor: `no_hardware_cursors = 1` (NVIDIA-safe; harmless on Intel).

## Commit 1 — shared session aspect (+ wm-exit, ironbar tweak)

1. `mkdir modules/desktop/session` and `git mv` these 7 from `modules/desktop/niri/`
   → `modules/desktop/session/`: `_bar.nix _launcher.nix _notifications.nix
   _idle-lock.nix _theming.nix _utils.nix _sunsetr.nix`.
2. In each moved file, change first header line "Niri/Wayland session only —" →
   "Wayland session stack (Niri + Hyprland) —" and drop stale "passed via
   -config/-c/-t/-C repo paths" comment lines (they now read default paths).
3. `modules/desktop/session/_utils.nix`: add a `wm-exit` wrapper to the packages:
   ```nix
   # Session-exit for the shared power menu: niri and Hyprland have different
   # quit commands — pick from the session environment.
   wmExit = pkgs.writeShellScriptBin "wm-exit" ''
     if [ -n "$NIRI_SOCKET" ]; then exec niri msg action quit; fi
     exec hyprctl dispatch exit
   '';
   ```
   and add `wmExit` to `environment.systemPackages`.
4. `dotfiles/niri/ironbar/config.json`: `"Log out"` on_click `!niri msg action quit` → `!wm-exit`.
5. New `modules/desktop/session.nix`:
   ```nix
   # Compositor-agnostic Wayland session stack shared by Niri and Hyprland.
   { flake, ... }: {
     flake.modules.nixos.session.imports = [
       ./session/_bar.nix
       ./session/_launcher.nix
       ./session/_notifications.nix
       ./session/_idle-lock.nix
       ./session/_theming.nix
       ./session/_utils.nix
       ./session/_sunsetr.nix
     ];
   }
   ```
6. `modules/desktop/niri/default.nix`: imports shrink to `[ ./_core.nix ]`; update
   the header comment (session stack lives in the `session` aspect).
7. `modules/hosts/manus.nix` + `spectre.nix`: add `flake.modules.nixos.session` to imports.
8. Gates: eval both hosts, build both toplevels, commit.

## Commit 2 — Hyprland aspect + Lua config + hjem + xremap branch

1. New `modules/desktop/hyprland/default.nix`:
   ```nix
   # Hyprland — third SDDM session (Plasma stays default), native scrolling layout.
   { flake, ... }: {
     flake.modules.nixos.hyprland.imports = [ ./_core.nix ];
   }
   ```
2. New `modules/desktop/hyprland/_core.nix`:
   ```nix
   { pkgs, ... }: {
     # SDDM session + xdg-desktop-portal-hyprland. No UWSM: we spawn the
     # session stack via exec-once-style autostart, like the Niri session.
     programs.hyprland.enable = true;
   }
   ```
3. Host aspects: add `flake.modules.nixos.hyprland` to imports (both hosts).
4. `modules/xremap.nix` (the approved additive change): in the `let` block add
   `xremapHyprland = pkgs.xremap.passthru.hyprland;` and extend `bridgeWrapper`:
   ```sh
   if [ "$XDG_CURRENT_DESKTOP" = "niri" ] || [ -n "$NIRI_SOCKET" ]; then
     exec ${xremapNiri}/bin/xremap --bridge
   fi
   if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
     exec ${xremapHyprland}/bin/xremap --bridge
   fi
   exec ${xremapKde}/bin/xremap --bridge
   ```
   (niri path stays first/unchanged; KDE remains the fallback.)
5. New `dotfiles/hyprland/hyprland.lua` — content sketch (final wording at impl):
   ```lua
   -- Hyprland config (0.56, Lua). Scrolling layout = Niri-style columns.
   -- xremap remaps below the compositor: binds see Graphite letters; each bind
   -- comments its QWERTY physical key (same convention as niri config.kdl).

   local mainMod = "SUPER"

   hl.config({
     general = {
       layout = "scrolling",
       gaps_in = 14,
       gaps_out = 14,
       border_size = 2,
       col = { active_border = "rgb(98971a)", inactive_border = "rgb(3c3836)" },
     },
     scrolling = {
       column_width = 0.5,
       explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
       focus_fit_method = 0,          -- center, like niri
       follow_focus = true,
       fullscreen_on_one_column = false,
     },
     input = {
       accel_profile = "flat",
       repeat_delay = 250,
       repeat_rate = 25,
       kb_options = "compose:ralt",
       follow_mouse = 1,
     },
     cursor = { no_hardware_cursors = 1 },  -- NVIDIA-safe; harmless on Intel
     decoration = { rounding = 0 },
     misc = { force_default_wallpaper = 0 },
   })

   hl.monitor({ output = "DP-3", mode = "1920x1080@239.964", position = "0x0", scale = 1 })

   hl.window_rule({ name = "steam-settings", match = { class = "steam", title = "Steam Settings" }, float = true })

   hl.on("hyprland.start", function()
     hl.exec_cmd("ironbar & swaync & swayidle -w & polkit-agent & wallpaper & sunsetr")
   end)

   -- binds: terminal/launcher, close/float/exit, focus (scroll l/r + column u/d),
   -- move window (standard move dispatcher crosses columns), consume/expel on
   -- Mod+comma/period (phys ' and ,), workspaces 1-9 focus+move,
   -- Mod+r colresize +conf, Mod+m fit expand, Mod+shift+f fit_into_view,
   -- Mod+minus/equal colresize ∓0.1, Mod+f layout-aware fullscreen,
   -- print→grim+slurp→wl-copy (+full-screen variant), Mod+l swaylock,
   -- Mod+shift+w wallpaper-picker, Mod+ctrl+c cliphist pipeline,
   -- Mod+shift+p dpms off via hl.timer pattern, XF86 keys as in config.kdl.
   ```
   (Fill in every bind explicitly; mirror config.kdl's comment style.)
6. `modules/users.nix`: add to `xdg.config.files`:
   `"hypr/hyprland.lua".source = ../dotfiles/hyprland/hyprland.lua;`
7. Gates:
   - eval + build both hosts
   - `nix eval .#nixosConfigurations.manus.config.programs.hyprland.enable` → true
   - `defaultSession` still `"plasma"`
   - wayland-sessions in the built toplevel contains `niri`, `Hyprland`, `plasma`
   - xremap unit JSON diff vs pre-change: ONLY the bridge wrapper `ExecStart` differs
   - hjem files list includes `hypr/hyprland.lua`
   - commit

## Commit 3 — docs

- README: header table sessions note ("Plasma (default) + Niri + Hyprland"),
  layout tree (add `desktop/session/`, `desktop/hyprland/`), post-install
  checklist third-session item, dotfiles section mention.
- TIPS: xremap section — bridge now picks kde/niri/hyprland variant.

## Post-switch (user)

`nh os switch`, pick "Hyprland" in SDDM, verify stack spawns + run through the
bind map. Rollback via boot menu generation.
