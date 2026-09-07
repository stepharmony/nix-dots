# X11 desktop aspect — xfce and cinnamon behind lightdm.
# Lives in the `x11` specialization (modules/specialisations.nix); the
# Wayland base stays untouched. Both DEs installed so they can be compared
# at the greeter — prune by taste later (one line each).
{ flake, ... }:

{
  flake.modules.nixos.x11 =
    { pkgs, ... }:
    {
      services.xserver.enable = true;

      # lightdm lists X11 sessions only — the natural greeter for this side.
      services.xserver.displayManager.lightdm.enable = true;

      services.xserver.desktopManager.xfce.enable = true;
      services.xserver.desktopManager.cinnamon.enable = true;

      # GTK desktops' utilities: disk usage analyzer + X11 clipboard CLI.
      # (The Wayland side has its own in session/_utils.nix: wl-clipboard.)
      environment.systemPackages = with pkgs; [
        baobab
        xclip
      ];
    };
}
