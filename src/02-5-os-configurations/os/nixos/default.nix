{ lib, username, ... }:
let
  # Keep the installed system's hardware, bootloader, users, and stateVersion.
  configPath = builtins.getEnv "NIXOS_CONFIG";
in
{
  imports = [
    (if configPath == "" then /etc/nixos/configuration.nix else builtins.toPath configPath)
  ];

  users.users.${username}.isNormalUser = lib.mkDefault true;
}
