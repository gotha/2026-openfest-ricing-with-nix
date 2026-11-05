{ pkgs, lib, ... }:
{
  home.packages =
    (with pkgs; [
      tmux
      # git is needed for TPM
      git
      nerd-fonts.iosevka
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wl-clipboard ];

  # Let Linux terminals discover the fonts in the Home Manager profile.
  fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

  home.file.".tmux.conf".source = ./tmux.conf;
}
