# Gaming tools (both hosts).
{ flake, ... }:

{
  flake.modules.nixos.gaming =
    { lib, pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        # protontricks-launch runs Windows tools (e.g. trainers) inside a game's prefix
        protontricks.enable = true;
      };

      # nested compositor for games that misbehave as plain niri/XWayland windows
      programs.gamescope.enable = true;

      environment.systemPackages = with pkgs; [
        prismlauncher
        protonplus
        faugus-launcher
        gpu-screen-recorder
        gpu-screen-recorder-ui
        gpu-screen-recorder-notification
      ];

      # A service, not niri's spawn-at-startup: gsr-ui died silently when spawned
      # at login. This logs to the journal and brings it back, whatever the exit
      # code; the Alt+Z bind in niri's config.kdl needs it running.
      systemd.user.services.gsr-ui = {
        description = "GPU Screen Recorder overlay";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        startLimitIntervalSec = 0;
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.gpu-screen-recorder-ui} launch-daemon";
          Restart = "always";
          RestartSec = 2;
        };
      };
    };
}
