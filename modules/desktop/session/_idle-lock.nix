# Wayland session stack (Niri) — screen lock, idle management,
# polkit agent. swayidle reads the default ~/.config/swayidle/config
# (deployed by hjem); swaylock likewise via the lock binds.
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
