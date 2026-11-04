{
  config,
  lib,
  pkgs,
  username,
  ...
}:
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
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  hardware.graphics.enable = true;
  programs.hyprlock.enable = true;
  # Home Manager owns the per-user idle daemon and its configuration.
  services.hypridle.enable = lib.mkForce false;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = lib.mkForce false;
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = lib.mkIf config.nixarchy.bluetooth.enable true;
  services.blueman.enable = config.nixarchy.bluetooth.enable;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  programs.dconf.enable = true;
  programs.nm-applet.enable = lib.mkForce false; # Home Manager owns the applet.
  services.udev.packages = [
    pkgs.brightnessctl
    pkgs.swayosd
  ];
  services.dbus.packages = [ pkgs.swayosd ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  fonts.fontconfig.enable = true;

  # Retain the host's login manager; provide a greeter on a minimal installation.
  services.greetd =
    lib.mkIf
      (
        !(
          config.services.displayManager.gdm.enable
          || config.services.displayManager.sddm.enable
          || config.services.displayManager.ly.enable
          || config.services.xserver.displayManager.lightdm.enable
        )
      )
      {
        enable = lib.mkDefault true;
        settings.default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd 'uwsm start hyprland.desktop'";
          user = "greeter";
        };
      };
}
