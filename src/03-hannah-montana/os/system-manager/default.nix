{
  config,
  lib,
  pkgs,
  username,
  homeDirectory,
  ...
}:
let
  sddmTheme = pkgs.callPackage ../../packages/sddm { };
in
{
  nix.enable = false;
  services.userborn.enable = false;
  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
  };
  # Keep desktop application closures out of system-manager's recursive /etc tree.
  home-manager.useUserPackages = false;
  home-manager.extraSpecialArgs.backend = "system-manager";
  system-graphics.enable = true;
  system-graphics.package = pkgs.mesa;
  environment.etc = lib.mkIf config.hannahMontana.loginTheme.enable {
    "sddm.conf.d/90-hannah-montana.conf".text = ''
      [Theme]
      Current=hannah-montana
    '';
  };
  systemd.tmpfiles.rules = lib.optionals config.hannahMontana.loginTheme.enable [
    "L+ /usr/share/sddm/themes/hannah-montana - - - - ${sddmTheme}/share/sddm/themes/hannah-montana"
  ];
  systemd.services.suid-sgid-wrappers.unitConfig.After = lib.mkForce "run-wrappers.mount";
  system-manager.preActivationAssertions.plasmaHost = {
    enable = true;
    script = ''
      for binary in /usr/bin/startplasma-wayland /usr/bin/plasmashell; do
        if ! test -x "$binary"; then
          echo "Install the host's Plasma 6 desktop first. See src/03-hannah-montana/README.md."
          exit 1
        fi
      done
      if ! plasma_version=$(/usr/bin/env -u QT_PLUGIN_PATH -u QML_IMPORT_PATH -u QML2_IMPORT_PATH \
        QT_QPA_PLATFORM=offscreen /usr/bin/plasmashell --version 2>/dev/null); then
        echo "Could not check the native Plasma version. Install the README prerequisites."
        exit 1
      fi
      case "$plasma_version" in
        *"plasmashell 6."*) ;;
        *) echo "This theme requires the host's Plasma 6 desktop."; exit 1 ;;
      esac
      for unit in dbus.service systemd-logind.service; do
        if ! /usr/bin/systemctl cat "$unit" >/dev/null 2>&1; then
          echo "Missing native desktop service: $unit"
          exit 1
        fi
      done
    '';
  };
}
