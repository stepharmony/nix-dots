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
      };
    };
}
