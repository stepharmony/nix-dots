# X11 desktop aspect — xfce (default) and qtile behind lightdm.
# Lives in the `x11` specialization (modules/specialisations.nix); the
# Wayland base stays untouched.
{ flake, ... }:

{
  flake.modules.nixos.x11 =
    { pkgs, ... }:
    {
      services.xserver.enable = true;

      # lightdm lists X11 sessions only — the natural greeter for this side.
      services.xserver.displayManager.lightdm.enable = true;

      services.xserver.desktopManager.xfce.enable = true;

      # Tiling WM alternative; config in dotfiles/qtile/config.py (hjem).
      services.xserver.windowManager.qtile.enable = true;

      # Cinnamon removed 2026-10: unstable on spectre. Worth retrying with
      # the next major Linux Mint release (Cinnamon ships with it) — re-add:
      #   services.xserver.desktopManager.cinnamon.enable = true;

      # GTK desktops' utilities: disk usage analyzer + X11 clipboard CLI.
      # (The Wayland side has its own in session/_utils.nix: wl-clipboard.)
      environment.systemPackages = with pkgs; [
        baobab
        xclip
        qalculate-gtk
      ];
    };
}
