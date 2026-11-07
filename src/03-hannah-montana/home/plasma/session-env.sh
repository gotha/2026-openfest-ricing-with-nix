# Plasma sources this before starting the desktop and importing its environment.
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  unset __ETC_PROFILE_NIX_SOURCED
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

hannah_state_profile="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
for hannah_profile in "$HOME/.nix-profile" "$hannah_state_profile"; do
  if [ -r "$hannah_profile/etc/profile.d/hm-session-vars.sh" ]; then
    # Home Manager's generated file can expand unset variables.
    case $- in *u*) hannah_restore_nounset=true; set +u ;; *) hannah_restore_nounset=false ;; esac
    . "$hannah_profile/etc/profile.d/hm-session-vars.sh"
    if "$hannah_restore_nounset"; then set -u; fi
    break
  fi
done
export PATH="$HOME/.nix-profile/bin:$hannah_state_profile/bin:${PATH:-/usr/bin:/bin}"
export XDG_DATA_DIRS="$HOME/.nix-profile/share:$hannah_state_profile/share:${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}/usr/local/share:/usr/share"
unset hannah_state_profile hannah_profile hannah_restore_nounset
