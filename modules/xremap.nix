# xremap — Graphite key remapping inside the graphical session.
# Replaces keyd (dormant: dotfiles/keyd/graphite.conf); note that TTYs and the
# SDDM greeter stay QWERTY — xremap only runs inside a graphical session.
{
  username,
  pkgs,
  ...
}:

let
  configFile = builtins.readFile ../dotfiles/xremap/graphite.yml;
in
{
  # xremap injects remapped keys through uinput.
  hardware.uinput.enable = true;

  # Give the logged-in user access to input devices and uinput.
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", TAG+="uaccess"
  '';
  users.users.${username}.extraGroups = [
    "input"
    "uinput"
  ];

  systemd.user.services.xremap = {
    description = "xremap key remapper (Graphite layout)";
    documentation = [ "https://github.com/xremap/xremap" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xremap.passthru.kde}/bin/xremap ${pkgs.writeText "xremap-graphite.yml" configFile}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    # restart the service whenever the layout file changes
    restartTriggers = [ (builtins.hashString "sha256" configFile) ];
  };
}
