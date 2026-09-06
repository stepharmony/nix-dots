# xremap — Graphite key remapping, official multi-DE architecture:
#
#   systemd.services.xremap       (system, dedicated `xremap` user)
#     socket-variant daemon doing the actual remapping (evdev → uinput)
#
#   systemd.user.services.xremap-bridge  (per graphical session)
#     feeds the active window from the running DE to the system service,
#     so application filters work under both KDE and Niri. The bridge
#     binary variant must match the running DE — picked at start.
#
# Replaces the old user-service setup; TTYs and the SDDM greeter stay QWERTY.
# Config: dotfiles/xremap/graphite.yml (the old keyd/kanata experiments live
# in git history). Alt+Esc toggles Graphite/QWERTY via xremap's native
# set_mode — config-internal, works in every DE and on TTYs; every boot
# re-seeds Graphite (mode state lives only in the daemon).
{ flake, ... }:

{
  flake.modules.nixos.xremap =
    {
      username,
      config,
      pkgs,
      ...
    }:

    let
      xremapKde = pkgs.xremap.passthru.kde;
      xremapNiri = pkgs.xremap.passthru.niri;
      xremapX11 = pkgs.xremap.passthru.x11;
      xremapSocket = pkgs.xremap.passthru.socket;

      # The bridge variant must match the running DE; detect from the session env.
      # niri first, KDE for Plasma, the generic X11 (wmctrl) bridge for xfce/
      # cinnamon/anything with a display — and a graceful idle when nothing is
      # supported, instead of crash-looping (Restart = always, no start limit).
      bridgeWrapper = pkgs.writeShellScriptBin "xremap-bridge" ''
        if [ "$XDG_CURRENT_DESKTOP" = "niri" ] || [ -n "$NIRI_SOCKET" ]; then
          exec ${xremapNiri}/bin/xremap --bridge
        fi
        if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
          exec ${xremapKde}/bin/xremap --bridge
        fi
        if [ -n "$DISPLAY" ]; then
          exec ${xremapX11}/bin/xremap --bridge
        fi
        exec sleep infinity
      '';

      configFile = builtins.readFile ../dotfiles/xremap/graphite.yml;
    in
    {
      hardware.uinput.enable = true;

      # /dev/input/event* → input group; /dev/uinput → uinput group.
      # Only the dedicated system user needs device access — not the desktop user.
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input"
      '';

      users.users.xremap = {
        isSystemUser = true;
        group = "xremap";
        extraGroups = [
          "input"
          "uinput"
        ];
        description = "xremap key remapper daemon";
      };
      users.groups.xremap = { };
      users.groups."xremap-${username}" = { };

      # The desktop user only needs socket access — no device access.
      users.users.${username}.extraGroups = [ "xremap-${username}" ];

      environment.etc."xremap/config.yml".source = ../dotfiles/xremap/graphite.yml;

      systemd.services.xremap = {
        description = "xremap key remapper (Graphite layout)";
        documentation = [ "https://github.com/xremap/xremap/blob/master/doc/running_as_system_service.md" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-udevd.service" ];
        serviceConfig = {
          User = "xremap";
          Group = "xremap";
          SupplementaryGroups = [
            "input"
            "uinput"
            "xremap-${username}"
          ];
          ExecStart = "${xremapSocket}/bin/xremap --watch=device /etc/xremap/config.yml";
          # per-user socket dir, writable by the bridge (xremap-rykard group)
          RuntimeDirectory = "xremap";
          RuntimeDirectoryMode = "0755";
          RuntimeDirectoryPreserve = true;
          ExecStartPre =
            "+"
            + (pkgs.writeShellScript "xremap-socket-dir" ''
              install --directory --mode 2770 --owner xremap --group xremap-${username} \
                "/run/xremap/$(id -u ${username})"
            '').outPath;
          Restart = "always";
          RestartSec = 2;
        };
        # restart the daemon whenever the layout file changes
        restartTriggers = [ (builtins.hashString "sha256" configFile) ];
      };

      systemd.user.services.xremap-bridge = {
        description = "xremap bridge (active window → system xremap)";
        documentation = [ "https://github.com/xremap/xremap/blob/master/doc/running_as_system_service.md" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${bridgeWrapper}/bin/xremap-bridge";
          Restart = "always";
          RestartSec = 1;
          # the DBus/session may not be ready right at login — retry quietly
          StartLimitBurst = 0;
        };
      };
    };
}
