# Boot-time Wayland/X11 split. The default boot is the unchanged Wayland
# system (Plasma + Niri via SDDM); these specializations add explicit
# systemd-boot entries. The X11 entry strips the Wayland stack and hands
# the greeter seat to lightdm (the two display managers cannot share it).
{ flake, ... }:

{
  flake.modules.nixos.specialisations =
    { flake, lib, ... }:
    {
      # Same as the default boot, but as a self-documenting menu entry.
      specialisation.wayland.configuration = {
        imports = [
          flake.modules.nixos.desktop
          flake.modules.nixos.niri
        ];
      };

      specialisation.x11.configuration = {
        imports = [ flake.modules.nixos.x11 ];

        # Strip the Wayland side; the packages stay but no sessions or
        # services come up, and lightdm only lists X11 sessions anyway.
        services.desktopManager.plasma6.enable = lib.mkForce false;
        programs.niri.enable = lib.mkForce false;
        services.displayManager.sddm.enable = lib.mkForce false;
        services.displayManager.defaultSession = lib.mkForce "xfce";
      };
    };
}
