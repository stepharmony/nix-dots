# The desktop user — defined once for both hosts; hosts add extraGroups.
# hjem manages rykard's $HOME (dotfiles in dotfiles/ deployed to ~/.config).
{ flake, ... }:

{
  flake.modules.nixos.users =
    { username, ... }:
    {
      # Define a user account. Don't forget to set a password with 'passwd'.
      users.users.${username} = {
        isNormalUser = true;
        description = username;
      };

      hjem.users.${username} = {
        user = username;
        directory = "/home/${username}";
        # clobber unmanaged files we take over (e.g. the previous manual
        # ~/.config/niri/config.kdl) on first switch
        clobberFiles = true;

        # Session dotfiles, deployed to each program's DEFAULT config
        # location — config.kdl then spawns plain binaries with no -c/-t/-C
        # flags and no absolute repo paths. Sources live in dotfiles/.
        xdg.config.files = {
          # Niri session: compositor + the classic tools it spawns
          "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
          "niri/wallpaper.png".source = ../dotfiles/niri/wallpaper.png; # swaybg
          "waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;
          "waybar/style.css".source = ../dotfiles/waybar/style.css;
          "fuzzel/fuzzel.ini".source = ../dotfiles/fuzzel/fuzzel.ini;
          "mako/config".source = ../dotfiles/mako/config;
          "swayidle/config".source = ../dotfiles/swayidle/config;
          "swaylock/config".source = ../dotfiles/swaylock/config;
          "sunsetr/sunsetr.toml".source = ../dotfiles/niri/sunsetr/sunsetr.toml;

          # Qtile (x11 boot entry only) — upstream default config + Graphite edits
          "qtile/config.py".source = ../dotfiles/qtile/config.py;

          # Tiling-session apps (niri + qtile): terminal + per-session defaults
          "kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
          "niri-mimeapps.list".source = ../dotfiles/xdg/tiling-mimeapps.list;
          "qtile-mimeapps.list".source = ../dotfiles/xdg/tiling-mimeapps.list;
        };
      };
    };
}
