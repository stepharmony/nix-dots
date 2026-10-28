# X11 desktop aspect — xfce (default) and qtile behind lightdm.
# Lives in the `x11` specialization (modules/specialisations.nix); the
# Wayland base stays untouched.
{ flake, ... }:

{
  flake.modules.nixos.x11 =
    { pkgs, ... }:
    {
      services.xserver.enable = true;

      # lightdm lists X11 sessions only — the natural greeter for this side.
      services.xserver.displayManager.lightdm.enable = true;

      services.xserver.desktopManager.xfce.enable = true;

      # Tiling WM alternative; config in dotfiles/qtile/config.py (hjem).
      services.xserver.windowManager.qtile.enable = true;

      # Cinnamon removed 2026-10: unstable on spectre. Worth retrying with
      # the next major Linux Mint release (Cinnamon ships with it) — re-add:
      #   services.xserver.desktopManager.cinnamon.enable = true;

      # GTK desktops' utilities: disk usage analyzer + X11 clipboard CLI.
      # (The Wayland side has its own in session/_utils.nix: wl-clipboard.)
      # qtile companions (spawned by its config.py autostart; rofi, kitty and
      # the other tiling apps come from the session aspect): notifications,
      # lock-on-idle/suspend, screen locker.
      environment.systemPackages = with pkgs; [
        dunst
        # HiDPI in qtile: config.py reads the output DPI (xrandr), sets
        # Xft.dpi (xrdb) and tells GTK the scale through XSETTINGS.
        xrandr
        xrdb
        xsettingsd
        xss-lock
        i3lock
        # i3lock in the wallpaper palette's surface colour (written by matugen;
        # xss-lock runs this, so each lock picks up the current colour).
        # Blue-light filter for qtile (sunsetr is Wayland-only): same values
        # as sunsetr, location from the timezone-derived geo.toml that
        # sunsetr-geo-sync writes (session/_sunsetr.nix). geo-sync stops
        # gammastep when the timezone changes; this loop restarts it with
        # the new coordinates, and ends on a real error (X server gone).
        (writeShellScriptBin "gammastep-tz" ''
          geo=''${XDG_CONFIG_HOME:-$HOME/.config}/sunsetr/geo.toml
          while :; do
            lat=$(${gawk}/bin/awk -F' *= *' '$1 == "latitude" { print $2 }' "$geo" 2>/dev/null)
            lon=$(${gawk}/bin/awk -F' *= *' '$1 == "longitude" { print $2 }' "$geo" 2>/dev/null)
            if [ -z "$lat" ] || [ -z "$lon" ]; then sleep 10; continue; fi
            ${gammastep}/bin/gammastep -m randr -t 6500:3300 -b 1.0:0.9 -l "$lat:$lon" || break
            sleep 1
          done
        '')
        (writeShellScriptBin "lock-x11" ''
          color=$(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/i3lock-color" 2>/dev/null || echo 18181b)
          exec ${i3lock}/bin/i3lock --nofork --color="$color"
        '')
        baobab
        xclip
        qalculate-gtk
      ];
    };
}
