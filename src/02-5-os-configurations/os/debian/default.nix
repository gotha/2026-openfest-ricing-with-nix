{ username, ... }:
{
  # Debian already manages Nix and the accounts in /etc/passwd.
  nix.enable = false;
  services.userborn.enable = false;

  # Describe the existing account for Home Manager and its per-user packages.
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
  };
}
