-- Hyprland config (0.56, Lua) — native scrolling layout (Niri-style tape).
-- Mirrors dotfiles/niri/config.kdl bind-for-bind so muscle memory carries
-- over between the two tiling sessions.
--
-- IMPORTANT: xremap remaps below the compositor, so binds here see *Graphite*
-- letters. Each bind comments its QWERTY physical key (same convention as
-- config.kdl). Identity keys in Graphite (c, v, g, /) are used for the most
-- muscle-memory-critical binds.

local mainMod = "SUPER"

hl.config({
  general = {
    layout = "scrolling",
    gaps_in = 14,
    gaps_out = 14,
    border_size = 2,
    col = {
      active_border = "rgb(98971a)", -- gruvbox bright green, as in niri
      inactive_border = "rgb(3c3836)",
    },
  },
  scrolling = {
    column_width = 0.5,
    explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
    focus_fit_method = 0, -- center the focused column, like niri
    follow_focus = true,
    fullscreen_on_one_column = false,
  },
  input = {
    accel_profile = "flat", -- 1:1 pointer, G502 X
    repeat_delay = 250,
    repeat_rate = 25,
    kb_options = "compose:ralt", -- Compose key, Niri/Hyprland sessions only
    follow_mouse = 1, -- focus follows the pointer
  },
  cursor = {
    no_hardware_cursors = 1, -- NVIDIA-safe; harmless on Intel
  },
  misc = {
    force_default_wallpaper = 0, -- no built-in background; awww applies ours
  },
})

-- Monitor: 27" 1080p gaming panel — exact refresh from EDID. Inert on
-- spectre (no DP-3 there). Scale stays 1.0 (intended).
hl.monitor({ output = "DP-3", mode = "1920x1080@239.964", position = "0x0", scale = 1 })

-- Steam settings and similar utility windows behave better floating.
hl.window_rule({
  name = "steam-settings",
  match = { class = "steam", title = "Steam Settings$" },
  float = true,
})

-- Start the session stack — the same daemons as the Niri session, all
-- reading their default $XDG_CONFIG_HOME locations (deployed by hjem).
-- The island (quickshell bar + notification daemon) runs alongside ironbar
-- and swaync until validated.
hl.on("hyprland.start", function()
  hl.exec_cmd("ironbar & swaync & swayidle -w & polkit-agent & wallpaper & sunsetr & qs -c island")
end)

-- Terminal + launcher (Space is layout-stable)
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("konsole"))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("rofi -show drun"))

-- Close / floating / quit — Graphite identity keys
hl.bind(mainMod .. " + C", hl.dsp.window.close()) -- phys C
hl.bind(mainMod .. " + V", hl.dsp.window.float()) -- phys V
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wm-exit")) -- phys E

-- Focus — arrows are primary; Graphite scrambles hjkl (h=phys J, j=phys P,
-- k=phys M, l=phys W), so no vim-key alternates. Left/right scroll the tape
-- and center the focused column; up/down move within the column.
hl.bind(mainMod .. " + Left", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + Right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "d" }))

-- First/last column of the tape
hl.bind(mainMod .. " + Home", hl.dsp.layout("fit tobeg"))
hl.bind(mainMod .. " + End", hl.dsp.layout("fit toend"))

-- Move windows/columns (left/right crosses columns, up/down reorders inside)
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }))

-- Consume/expel — the scrollable-layout signature moves
-- (Graphite: , is on phys ', . is on phys ,)
hl.bind(mainMod .. " + comma", hl.dsp.layout("consume")) -- phys '
hl.bind(mainMod .. " + period", hl.dsp.layout("expel")) -- phys ,

-- Workspaces
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + Page_Up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + Page_Down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + Page_Up", hl.dsp.window.move({ workspace = "e-1" }))

-- Monitors
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.window.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ monitor = "d" }))

-- Size / fullscreen — remember these fire on Graphite outputs.
-- Fullscreen uses the scrolling layout's own handler, so fullscreen windows
-- stay part of the tape and you can scroll away from them.
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", layout_aware = true })) -- phys U
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf")) -- phys R
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.layout("fit_into_view")) -- phys U + shift
hl.bind(mainMod .. " + M", hl.dsp.layout("fit expand")) -- phys M
hl.bind(mainMod .. " + minus", hl.dsp.layout("colresize -0.1")) -- phys .
hl.bind(mainMod .. " + equal", hl.dsp.layout("colresize +0.1")) -- phys ]

-- Screenshots — grim+slurp region to clipboard; Mod+Print grabs everything.
-- (Niri's built-in screenshot UI has no Hyprland equivalent.)
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy')) -- phys F

-- Lock / exit session
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock")) -- phys W

-- Power off monitors — dpms must not run on the event loop, hence the timer.
hl.bind(mainMod .. " + SHIFT + P", function()
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
  end, { timeout = 500, type = "oneshot" })
end)

-- Wallpaper picker (fires from phys Q — Shift avoids accidental launch)
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("wallpaper-picker"))

-- Clipboard history picker
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- Island notification center (phys B)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs -c island ipc call island toggleNotifCenter"))

-- Hardware keys — layout-independent
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
