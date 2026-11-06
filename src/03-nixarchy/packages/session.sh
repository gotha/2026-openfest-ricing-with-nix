if [[ ${1:-} == --help ]]; then
  echo 'Run nixarchy-session from a local TTY or select Nixarchy at the login screen.'
  exit 0
fi

# Display managers need the same paths as a login shell. UWSM passes these to
# the compositor and its graphical-session services.
stateProfile="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:$stateProfile/bin:/etc/profiles/per-user/$USER/bin:/run/system-manager/sw/bin:/run/current-system/sw/bin:$PATH"
# Keep the host's data paths even when the inherited value only lists Nix profiles.
export XDG_DATA_DIRS="$HOME/.nix-profile/share:$stateProfile/share:/etc/profiles/per-user/$USER/share:/run/system-manager/sw/share:/run/current-system/sw/share:${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}/usr/local/share:/usr/share"
for profile in "$HOME/.nix-profile" "$stateProfile" "/etc/profiles/per-user/$USER"; do
  if [[ -r "$profile/etc/profile.d/hm-session-vars.sh" ]]; then
    # Home Manager's profile may expand unset variables such as XCURSOR_PATH.
    set +u
    # shellcheck source=/dev/null
    source "$profile/etc/profile.d/hm-session-vars.sh"
    set -u
    break
  fi
done
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
exec uwsm start -F -D Hyprland -- start-hyprland
