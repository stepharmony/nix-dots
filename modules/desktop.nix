# Plasma 6 (Wayland) — the default SDDM session on both hosts.
{ flake, ... }:

{
  flake.modules.nixos.desktop =
    { lib, pkgs, ... }:
    {
      # Enable the KDE Plasma Desktop Environment.
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      # Keep Plasma as the SDDM default even with niri enabled
      # (the niri module mkDefaults its own session; lower number wins).
      services.displayManager.defaultSession = lib.mkOverride 900 "plasma";

      # Oxygen theme family (selectable in System Settings → Colors & Themes).
      environment.systemPackages = with pkgs; [
        kdePackages.oxygen
        kdePackages.oxygen-sounds
        kdePackages.oxygen-icons
        kdePackages.filelight
      ];
    };
}
