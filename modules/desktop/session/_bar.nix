# Wayland session stack (Niri) — waybar, spawned by config.kdl. Config
# deployed by hjem to ~/.config/waybar/ (dotfiles/waybar/).
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.waybar ];

  # Obel Mono (overlays/, not in nixpkgs yet) is the session's text font;
  # JetBrains Mono with the full Nerd Font glyph set stays as the fallback
  # for icons, which Obel Mono lacks. System defaults: modules/fonts.nix.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.obel-mono
  ];

  # EasyEffects' own "start on login" is an XDG autostart entry, which runs
  # alongside waybar; when it wins the race there is no tray
  # (StatusNotifierWatcher) yet, and it never adds its icon later. Hold it
  # until the tray is up — 10 s at most, so a session without one only
  # starts it late. A drop-in on the generated unit: harmless while the
  # autostart entry is off. A raw unit, not systemd.user.services: that would
  # add its own PATH= to the drop-in, replacing the one autostart relies on.
  systemd.user.units."app-com.github.wwmm.easyeffects@autostart.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Service]
      ExecStartPre=-${pkgs.glib.bin}/bin/gdbus wait --session --timeout 10 org.kde.StatusNotifierWatcher
    '';
  };
}
