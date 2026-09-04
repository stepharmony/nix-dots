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

        # Niri session rice, deployed to each program's DEFAULT config
        # location — config.kdl then spawns plain binaries with no -c/-t/-C
        # flags and no absolute repo paths. Sources live in dotfiles/niri/.
        xdg.config.files = {
          "niri/config.kdl".source = ../dotfiles/niri/config.kdl;
          "ironbar/config.json".source = ../dotfiles/niri/ironbar/config.json;
          "ironbar/style.css".source = ../dotfiles/niri/ironbar/style.css;
          "swaync/config.json".source = ../dotfiles/niri/swaync/config.json;
          "swaync/style.css".source = ../dotfiles/niri/swaync/style.css;
          "swayidle/config".source = ../dotfiles/niri/swayidle/config;
          "rofi/config.rasi".source = ../dotfiles/niri/rofi/config.rasi;
          # swaylock reads $XDG_CONFIG_HOME/swaylock/config by default
          "swaylock/config".source = ../dotfiles/niri/swaylock.conf;
          "sunsetr/sunsetr.toml".source = ../dotfiles/niri/sunsetr/sunsetr.toml;
          # Hyprland session (Lua config — hyprlang is deprecated since 0.55)
          "hypr/hyprland.lua".source = ../dotfiles/hyprland/hyprland.lua;
        };
      };
    };
}
