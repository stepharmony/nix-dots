# Niri/Wayland session only — screen lock, idle management, polkit agent.
# swayidle is spawned with a repo config file (-C) from config.kdl; swaylock
# reads its gruvbox conf via -C on the lock bind.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swaylock
    swayidle
    # GUI polkit authentication agent — the Niri session has no DE to provide
    # one. Exposed on PATH via a tiny wrapper: the agent itself lives in
    # libexec, which is not on PATH.
    (pkgs.writeShellScriptBin "polkit-agent" ''
      exec ${pkgs.lxqt.lxqt-policykit}/libexec/polkit-lxqt-1-agent
    '')
  ];
}
