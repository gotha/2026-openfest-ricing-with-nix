{
  config,
  lib,
  pkgs,
  username,
  homeDirectory,
  ...
}:
let
  desktop = pkgs.writeText "nixarchy.desktop" ''
    [Desktop Entry]
    Name=Nixarchy
    Comment=Hyprland desktop managed by Nix and Home Manager
    Exec=${pkgs.callPackage ../../packages { }}/bin/nixarchy-session
    Type=Application
    DesktopNames=Hyprland
  '';
in
{
  nix.enable = false;
  services.userborn.enable = false;
  # System-manager recursively resolves /etc entries, including dangling icon links.
  # Install desktop packages in Home Manager's own profile instead.
  home-manager.useUserPackages = false;
  home-manager.extraSpecialArgs.backend = "system-manager";
  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
  };
  system-graphics.enable = true;
  system-graphics.package = pkgs.mesa;
  environment.systemPackages = [ pkgs.uwsm ];
  environment.etc."nixarchy/session.desktop".source = desktop;
  # A unique session entry leaves Debian's existing login sessions intact.
  systemd.tmpfiles.rules = [
    "L+ /usr/share/wayland-sessions/nixarchy.desktop - - - - ${desktop}"
  ];
  systemd.packages = [ pkgs.uwsm ];

  # Use the same local-password PAM modules and helper as NixOS. Absolute paths
  # avoid loading Debian's PAM modules into the Nix-built lock screen.
  environment.etc."pam.d/hyprlock".text = lib.mkDefault ''
    auth required ${pkgs.pam}/lib/security/pam_unix.so try_first_pass
    account required ${pkgs.pam}/lib/security/pam_unix.so
  '';
  security.wrappers.unix_chkpwd = {
    source = "${pkgs.pam}/bin/unix_chkpwd";
    owner = "root";
    group = "root";
    setuid = true;
  };
  system-manager.preActivationAssertions.debianDesktop = {
    enable = true;
    script = ''
      for unit in dbus.service systemd-logind.service NetworkManager.service; do
        if ! /usr/bin/systemctl cat "$unit" >/dev/null 2>&1; then
          echo "Missing Debian desktop service: $unit. See the Nixarchy README prerequisites."
          exit 1
        fi
      done
    '';
  };
}
