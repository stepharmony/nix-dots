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
      # Skip upstream's pytest suite: its headless GUI tests segfault in the
      # build sandbox. The rest of installCheckPhase still runs.
      winpodx = inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        dontUsePytestCheck = true;
      };
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
