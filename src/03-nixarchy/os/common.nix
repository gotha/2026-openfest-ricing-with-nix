{
  config,
  lib,
  username,
  ...
}:
{
  options.nixarchy.bluetooth.enable = lib.mkEnableOption "Bluetooth support on this host";
  config = {
    environment.pathsToLink = [
      "/share"
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    assertions = [
      {
        assertion = username != "" && username != "root";
        message = "Run as your desktop user, or set NIXARCHY_USER to the existing desktop account.";
      }
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = lib.mkDefault true;
      backupFileExtension = "before-nixarchy";
      extraSpecialArgs.bluetooth = config.nixarchy.bluetooth.enable;
      users.${username} = import ../home;
    };
  };
}
