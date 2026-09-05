# X11 desktop aspect — xfce and cinnamon behind lightdm.
# Lives in the `x11` specialization (modules/specialisations.nix); the
# Wayland base stays untouched. Both DEs installed so they can be compared
# at the greeter — prune by taste later (one line each).
{ flake, ... }:

{
  flake.modules.nixos.x11 =
    { ... }:
    {
      services.xserver.enable = true;

      # lightdm lists X11 sessions only — the natural greeter for this side.
      services.xserver.displayManager.lightdm.enable = true;

      services.xserver.desktopManager.xfce.enable = true;
      services.xserver.desktopManager.cinnamon.enable = true;
    };
}
