# Wayland session stack (Niri) — screen lock, idle management,
# polkit agent. swayidle reads the default ~/.config/swayidle/config
# (deployed by hjem); swaylock likewise via the lock binds.
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    swaylock
    swayidle
    # GUI polkit authentication agent — the Niri session has no DE to provide
    # one. Exposed under a stable name (spawned by config.kdl and qtile):
    # lxqt-policykit 2.4 moved the agent from libexec/polkit-lxqt-1-agent to
    # bin/lxqt-policykit-agent, which silently broke the old path.
    (pkgs.writeShellScriptBin "polkit-agent" ''
      exec ${lib.getExe' pkgs.lxqt.lxqt-policykit "lxqt-policykit-agent"}
    '')
  ];
}
