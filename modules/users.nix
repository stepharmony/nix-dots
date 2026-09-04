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
          "swayidle/config".source = ../dotfiles/niri/swayidle/config;
          "rofi/config.rasi".source = ../dotfiles/niri/rofi/config.rasi;
          # swaylock reads $XDG_CONFIG_HOME/swaylock/config by default
          "swaylock/config".source = ../dotfiles/niri/swaylock.conf;
          "sunsetr/sunsetr.toml".source = ../dotfiles/niri/sunsetr/sunsetr.toml;

          # The custom quickshell island — spawned as `qs -c island` by the
          # Niri session. Palette comes from matugen (below); gruvbox
          # fallbacks are baked into Theme.qml.
          "quickshell/island/shell.qml".source = ../dotfiles/quickshell/island/shell.qml;
          "quickshell/island/qmldir".source = ../dotfiles/quickshell/island/qmldir;
          "quickshell/island/Theme.qml".source = ../dotfiles/quickshell/island/Theme.qml;
          "quickshell/island/Wm.qml".source = ../dotfiles/quickshell/island/Wm.qml;
          "quickshell/island/Notifs.qml".source = ../dotfiles/quickshell/island/Notifs.qml;
          "quickshell/island/Bar.qml".source = ../dotfiles/quickshell/island/Bar.qml;
          "quickshell/island/WorkspacesRow.qml".source = ../dotfiles/quickshell/island/WorkspacesRow.qml;
          "quickshell/island/MediaPill.qml".source = ../dotfiles/quickshell/island/MediaPill.qml;
          "quickshell/island/PillButton.qml".source = ../dotfiles/quickshell/island/PillButton.qml;
          "quickshell/island/SlidersPill.qml".source = ../dotfiles/quickshell/island/SlidersPill.qml;
          "quickshell/island/TrayRow.qml".source = ../dotfiles/quickshell/island/TrayRow.qml;
          "quickshell/island/PowerRow.qml".source = ../dotfiles/quickshell/island/PowerRow.qml;
          "quickshell/island/NotifCenter.qml".source = ../dotfiles/quickshell/island/NotifCenter.qml;
          "quickshell/island/Toasts.qml".source = ../dotfiles/quickshell/island/Toasts.qml;

          # matugen: wallpaper -> Material You palette -> island colors
          "matugen/config.toml".source = ../dotfiles/matugen/config.toml;
          "matugen/templates/island-colors.json".source = ../dotfiles/matugen/templates/island-colors.json;
        };
      };
    };
}
