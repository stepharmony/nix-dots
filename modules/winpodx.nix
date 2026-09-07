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
        # 0.11.0 (flake update, Sep 7) made builds hostile: upstream added its
        # pytest suite (GUI tests, ~1h headless in the sandbox) AND its python
        # packaging shadows overrideAttrs/overridePythonAttrs into shapes the
        # NixOS option type check rejects. Pinned back via flake.lock
        # (--override-input) until upstream cleans up; try the bump again later.
        inputs.winpodx.packages.${pkgs.system}.default
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
