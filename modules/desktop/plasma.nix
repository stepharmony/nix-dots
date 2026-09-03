{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./wayland.nix
  ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Oxygen theme family (selectable in System Settings → Colors & Themes).
  environment.systemPackages = with pkgs; [
    kdePackages.oxygen
    kdePackages.oxygen-sounds
    kdePackages.oxygen-icons
  ];
}
