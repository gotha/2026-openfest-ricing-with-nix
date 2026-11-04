{ config, lib, ... }:
{
  programs.bash = {
    enable = true;

    # Load Nix before completion initialization in interactive terminals and tmux.
    initExtra = lib.mkOrder 50 ''
      if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # A parent shell may have set this before Debian's profile reset PATH.
        unset __ETC_PROFILE_NIX_SOURCED
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      elif [[ -r "${config.home.profileDirectory}/etc/profile.d/nix.sh" ]]; then
        source "${config.home.profileDirectory}/etc/profile.d/nix.sh"
      fi
    '';
  };
}
