# Boot-time Wayland/X11 split. The default (base) boot IS the unchanged
# Wayland system (Plasma + Niri via SDDM); the x11 specialisation adds a
# separate menu entry that strips the Wayland stack and hands the greeter
# seat to lightdm (the two display managers cannot share it). Limine groups
# each generation + its specialisation in a boot-menu submenu.
{ flake, ... }:

{
  flake.modules.nixos.specialisations =
    { flake, lib, ... }:
    {
      specialisation.x11.configuration = {
        imports = [ flake.modules.nixos.x11 ];

        environment.etc."specialisation".text = "x11";

        # Strip the Wayland side; the packages stay but no sessions or
        # services come up, and lightdm only lists X11 sessions anyway.
        services.desktopManager.plasma6.enable = lib.mkForce false;
        programs.niri.enable = lib.mkForce false;
        services.displayManager.sddm.enable = lib.mkForce false;
        services.displayManager.defaultSession = lib.mkForce "xfce";
      };
    };
}
