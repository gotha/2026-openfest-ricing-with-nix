{
  imports = [
    ./applications.nix
    ./theme
    ./plasma
    ./plasma/session.nix
  ];
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.bash.initExtra = ''
    if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      unset __ETC_PROFILE_NIX_SOURCED
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
  '';
  home.sessionVariables = {
    BROWSER = "firefox";
    EDITOR = "kate";
    TERMINAL = "konsole";
  };
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
