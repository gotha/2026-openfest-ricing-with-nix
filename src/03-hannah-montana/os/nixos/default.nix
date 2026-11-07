{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  theme = pkgs.callPackage ../../packages/theme.nix { };
  sddmTheme = pkgs.callPackage ../../packages/sddm { };
in
{
  home-manager.extraSpecialArgs.backend = "nixos";
  users.users.${username} = {
    isNormalUser = lib.mkDefault true;
    extraGroups = [
      "networkmanager"
      "video"
      "render"
    ];
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = lib.mkIf config.hannahMontana.loginTheme.enable {
    enable = lib.mkDefault (
      !(
        config.services.displayManager.gdm.enable
        || config.services.displayManager.ly.enable
        || config.services.xserver.displayManager.lightdm.enable
        || config.services.greetd.enable
      )
    );
    theme = "hannah-montana";
    extraPackages = [ pkgs.kdePackages.qtdeclarative ];
  };
  environment.systemPackages = [
    theme
  ]
  ++ lib.optional config.hannahMontana.loginTheme.enable sddmTheme;
  hardware.graphics.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pulseaudio.enable = lib.mkForce false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = lib.mkIf config.hannahMontana.bluetooth.enable true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  programs.dconf.enable = true;
  programs.kde-pim.enable = config.hannahMontana.extras.enable;
  fonts.fontconfig.enable = true;
  boot.plymouth = lib.mkIf config.hannahMontana.plymouth.enable {
    enable = true;
    logo = "${theme}/share/icons/hannah-montana-logo.png";
    theme = "breeze";
    themePackages = [
      (pkgs.kdePackages.breeze-plymouth.override {
        logoFile = "${theme}/share/icons/hannah-montana-logo.png";
        logoName = "hannah-montana";
        osName = "Hannah Montana";
      })
    ];
  };
}
