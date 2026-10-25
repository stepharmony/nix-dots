# Wayland session stack (Niri) — fuzzel launcher (Mod+D) and dmenu for the
# clipboard picker. Config deployed by hjem to ~/.config/fuzzel/fuzzel.ini.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fuzzel ];
}
