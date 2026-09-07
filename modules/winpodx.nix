# WinPodX — Windows apps as native Linux windows (FreeRDP RemoteApp +
# dockur/windows in rootless Podman). The package wrapper self-injects its
# runtime tools (FreeRDP, Podman, podman-compose, iproute2, libnotify).
#
# First pod boot downloads a ~7.5 GB Windows ISO from Microsoft and Syspreps
# it — bring your own license key (Home / Pro / Enterprise all supported by
# dockur).
{ flake, ... }:

{
  flake.modules.nixos.winpodx =
    {
      inputs,
      pkgs,
      username,
      ...
    }:
    {
      environment.systemPackages = [
        # doCheck=false: upstream's pytest suite (GUI tests, headless sandbox)
        # takes ~1h per rev — their CI concern, not our build's.
        inputs.winpodx.packages.${pkgs.system}.default.overrideAttrs
        (_: {
          doCheck = false;
        })
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
