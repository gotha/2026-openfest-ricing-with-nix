{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
    # git is needed for TPM
    git
    # Match dotfiles/config/fonts.nix for Powerline glyph support.
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.noto
    nerd-fonts.ubuntu
  ];

  # Let Linux terminals discover the fonts in the Home Manager profile.
  fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

  home.file.".tmux.conf".source = ./tmux.conf;
}
