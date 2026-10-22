# WinPodX — Windows apps as native Linux windows (FreeRDP RemoteApp +
# dockur/windows in rootless Podman). The package wrapper self-injects its
# runtime tools (FreeRDP, Podman, podman-compose, iproute2, libnotify).
{ flake, ... }:

{
  flake.modules.nixos.winpodx =
    {
      inputs,
      pkgs,
      username,
      ...
    }:
    let
      # Disable upstream's headless GUI tests so it builds without segfaulting
      winpodx = inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        dontUsePytestCheck = true;
        doInstallCheck = true;
      });
    in
    {
      environment.systemPackages = [
        winpodx
      ];

      # Rootless Podman hosts the Windows pod (dockur backend); dns_enabled
      # is the standard netavark networking requirement.
      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      # The Windows VM wants hardware KVM (both hosts load their kvm modules).
      users.users.${username}.extraGroups = [ "kvm" ];
    };
}
