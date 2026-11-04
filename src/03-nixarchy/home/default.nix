{ lib, pkgs, ... }:
{
  _module.args.bluetooth = lib.mkDefault false;
  imports = [
    ./theme
    ./terminal
    ./tmux
    ./neovim
    ./applications.nix
    ./desktop
  ];
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  home.packages = [ (pkgs.callPackage ../packages { }) ];
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    TERMINAL = "foot";
    BROWSER = "chromium";
  };
  xdg.enable = true;
  systemd.user.startServices = "sd-switch";
}
