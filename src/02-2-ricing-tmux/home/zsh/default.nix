{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;

    # Home Manager loads its session variables through .zshenv automatically.
    # Initialize Nix for interactive terminals and tmux, after system profiles.
    initContent = lib.mkBefore ''
      if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # A parent shell may have set this before a system profile reset PATH.
        unset __ETC_PROFILE_NIX_SOURCED
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      elif [[ -r "${config.home.profileDirectory}/etc/profile.d/nix.sh" ]]; then
        source "${config.home.profileDirectory}/etc/profile.d/nix.sh"
      fi
    '';
  };
}
