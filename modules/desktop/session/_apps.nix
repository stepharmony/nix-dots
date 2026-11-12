# Tiling-session default apps (niri + qtile; XFCE keeps its own). Chosen
# to be GTK3 or toolkit-free, so the per-session
# theming (GTK_THEME / qt6ct, set only by niri and qtile) fully applies.
# Defaults per session: dotfiles/xdg/tiling-mimeapps.list, deployed as
# niri-mimeapps.list and qtile-mimeapps.list (XDG reads those only when
# XDG_CURRENT_DESKTOP matches, so XFCE's defaults are untouched).
#
# The terminal, in two places:
# - Terminal=true apps (Helix, btop, …): GLib's own terminal list has no
#   kitty, so they go through xdg-terminal-exec, set to kitty below.
# - Thunar's "Open Terminal Here" runs `exo-open --launch TerminalEmulator`,
#   XFCE's preferred-applications lookup: exo-open, xfce4-mime-helper with
#   its helper definitions, and a helpers.rc choosing kitty. The XFCE boot
#   (x11 specialisation) ships its own and keeps them; a choice made in its
#   Preferred Applications lands in ~/.config/xfce4/helpers.rc and wins
#   everywhere.
{
  pkgs,
  lib,
  config,
  ...
}:
let
  xfce = config.services.xserver.desktopManager.xfce.enable;
in
{
  environment.systemPackages =
    with pkgs;
    [
      kitty # terminal: ligatures, transparency (dotfiles/kitty/kitty.conf)
      xarchiver # archives (also Thunar's right-click extract/compress)
      zathura # PDF (keyboard-driven); Okular stays for annotations
      imv # images
    ]
    ++ lib.optionals (!xfce) [
      xfce4-exo # exo-open
      # exo-open hands the lookup to xfce4-mime-helper; it and the helper
      # definitions (kitty among them) without the rest of xfce4-settings.
      (runCommand "xfce4-mime-helper" { } ''
        mkdir -p $out/bin $out/share/xfce4
        ln -s ${xfce4-settings}/bin/xfce4-mime-helper $out/bin/
        ln -s ${xfce4-settings}/share/xfce4/helpers $out/share/xfce4/helpers
      '')
    ];

  # The XFCE module links this into the system profile; without it, nothing
  # does and the helpers above stay out of /run/current-system/sw/share.
  environment.pathsToLink = lib.mkIf (!xfce) [ "/share/xfce4" ];

  environment.etc."xdg/xfce4/helpers.rc" = lib.mkIf (!xfce) {
    text = ''
      TerminalEmulator=kitty
    '';
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "kitty.desktop" ];
      XFCE = [ "xfce4-terminal.desktop" ]; # XFCE keeps its own
    };
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      # The plugin looks for <manager>.tap only in its own libexec, but
      # xarchiver ships xarchiver.tap in its package — without the link,
      # "Create Archive" finds "no suitable archive manager".
      (thunar-archive-plugin.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          ln -s ${xarchiver}/libexec/thunar-archive-plugin/xarchiver.tap $out/libexec/thunar-archive-plugin/
        '';
      }))
      thunar-volman
    ];
  };
  services.tumbler.enable = true; # thumbnails
  services.gvfs.enable = true; # trash, removable drives, network mounts
}
