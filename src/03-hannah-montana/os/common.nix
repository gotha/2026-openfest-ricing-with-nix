{
  config,
  lib,
  username,
  ...
}:
{
  options.hannahMontana = {
    extras.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install mail, chat, games, painting, and disc-authoring applications from the plan.";
    };
    bluetooth.enable = lib.mkEnableOption "Bluetooth support on this host";
    loginTheme.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Configure the Hannah Montana SDDM login theme.";
    };
    plymouth.enable = lib.mkEnableOption "the branded NixOS boot splash";
  };
  config = {
    assertions = [
      {
        assertion = username != "" && username != "root";
        message = "Run as your desktop user, or set HANNAH_MONTANA_USER to an existing desktop account.";
      }
    ];
    environment.pathsToLink = [ "/share" ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = lib.mkDefault true;
      backupFileExtension = "before-hannah-montana";
      extraSpecialArgs.extras = config.hannahMontana.extras.enable;
    };
  };
}
