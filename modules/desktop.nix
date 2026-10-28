# Display manager + shared theme for the Wayland (base) boot on both hosts.
# ly lists every installed session; niri's module mkDefaults it as the
# default. The x11 specialisation swaps ly for lightdm (specialisations.nix).
{ flake, ... }:

{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # TTY greeter; its PAM stack includes `login`, so gnome-keyring unlocks
      # at login like before.
      services.displayManager.ly.enable = true;

      # Oxygen cursor (Oxygen_White) and icons — referenced by the GTK
      # settings.ini, qt6ct and rofi, so they outlive Plasma.
      environment.systemPackages = with pkgs; [
        kdePackages.oxygen
        kdePackages.oxygen-icons
      ];
    };
}
