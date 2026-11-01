{ pkgs, ... }:
{
  imports = [ ./tmux ];

  home = {
    packages = [
      pkgs.cowsay
      pkgs.neovim
    ];
    # Keep this value when updating an existing installation.
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
