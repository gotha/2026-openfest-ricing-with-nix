{ ... }:
let
  configPath = builtins.getEnv "NIXOS_CONFIG";
in
{
  imports = [
    (if configPath == "" then /etc/nixos/configuration.nix else builtins.toPath configPath)
  ];
}
