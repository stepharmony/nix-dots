# The desktop user — defined once for both hosts; hosts add extraGroups.
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
    };
}
