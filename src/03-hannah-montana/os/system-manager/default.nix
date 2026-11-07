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
  plasma = pkgs.callPackage ../../packages/plasma { };
  desktopEntry = pkgs.writeText "hannah-montana.desktop" ''
    [Desktop Entry]
    Name=Hannah Montana (Plasma Wayland)
    Comment=Plasma desktop managed by Nix and Home Manager
    Exec=${plasma.session}/bin/hannah-montana-session
    TryExec=${plasma.session}/bin/hannah-montana-session
    Type=Application
    DesktopNames=KDE
  '';
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
  environment.etc = {
    "hannah-montana/session.desktop".source = desktopEntry;
    "sddm.conf.d/90-hannah-montana.conf" = lib.mkIf config.hannahMontana.loginTheme.enable {
      text = ''
        [Theme]
        Current=hannah-montana
      '';
    };
    "dbus-1/system.d/hannah-montana.conf".text = ''
      <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
        "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <servicedir>${plasma.desktop}/share/dbus-1/system-services</servicedir>
        <includedir>${plasma.desktop}/share/dbus-1/system.d</includedir>
      </busconfig>
    '';
    # The Nix-built lock screen must load matching PAM modules and password helper.
    "pam.d/kde".text = ''
      auth required ${pkgs.pam}/lib/security/pam_unix.so try_first_pass
      account required ${pkgs.pam}/lib/security/pam_unix.so
    '';
  };
  systemd.tmpfiles.packages = [ plasma.hostIntegration ];
  systemd.tmpfiles.rules = [
    "L+ /usr/share/wayland-sessions/hannah-montana.desktop - - - - ${desktopEntry}"
  ]
  ++ lib.optionals config.hannahMontana.loginTheme.enable [
    "L+ /usr/share/sddm/themes/hannah-montana - - - - ${sddmTheme}/share/sddm/themes/hannah-montana"
  ];
  security.wrappers = {
    kwin_wayland = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_nice+ep";
      source = "${pkgs.kdePackages.kwin}/bin/kwin_wayland";
    };
    unix_chkpwd = {
      owner = "root";
      group = "root";
      setuid = true;
      source = "${pkgs.pam}/bin/unix_chkpwd";
    };
  };
  systemd.services.suid-sgid-wrappers.unitConfig.After = lib.mkForce "run-wrappers.mount";
  system-manager.preActivationAssertions.desktopHost = {
    enable = true;
    script = ''
      for unit in dbus.service systemd-logind.service NetworkManager.service polkit.service; do
        if ! /usr/bin/systemctl cat "$unit" >/dev/null 2>&1; then
          echo "Missing native desktop service: $unit. Keep Debian's host services installed."
          exit 1
        fi
      done
    '';
  };
}
