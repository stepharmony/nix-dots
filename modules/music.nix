# Music production tools (both hosts).
{ flake, ... }:

{
  flake.modules.nixos.music =
    { pkgs, ... }:
    {
      # Bitwig Studio 6.1, hard-pinned (see overlays/default.nix + TIPS.md).
      # Theming: drop a modified bitwig.jar at ~/.config/bitwig/bitwig.jar —
      # the launcher bind-mounts it over the stock jar at launch.
      environment.systemPackages = with pkgs; [
        bitwig-studio
        freetype
        cabextract
      ];

      # commented till i figure out wtf to do with this
      # in the meantime:
      # nix-shell -p steam-run --run "steam-run sh ableton-wine-setup-2026.07.29.1.run"
      #   programs.nix-ld.enable = true;
      #
      #   programs.nix-ld.libraries = with pkgs; [
      #     pipewire
      #     libjack2
      #     alsa-lib
      #   ];
    };
}
