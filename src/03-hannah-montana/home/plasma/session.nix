{
  lib,
  pkgs,
  backend ? "nixos",
  ...
}:
let
  plasma = pkgs.callPackage ../../packages/plasma { };
in
{
  config = lib.mkIf (backend == "system-manager") {
    home.packages = [
      plasma.desktop
      plasma.session
    ];
    systemd.user.packages = [ plasma.desktop ];
    # The session bus already watches ~/.local/share, including at first activation.
    xdg.dataFile."dbus-1/services" = {
      source = "${plasma.desktop}/share/dbus-1/services";
      recursive = true;
    };
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gtk
      ];
      config.kde.default = [
        "kde"
        "gtk"
      ];
    };
  };
}
