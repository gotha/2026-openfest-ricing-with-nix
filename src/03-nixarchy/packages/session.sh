if [[ ${1:-} == --help ]]; then
  echo 'Run nixarchy-session from a local TTY or select Nixarchy at the login screen.'
  exit 0
fi

# Display managers need the same paths as a login shell. UWSM passes these to
# the compositor and its graphical-session services.
export PATH="/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/run/system-manager/sw/bin:/run/current-system/sw/bin:$PATH"
export XDG_DATA_DIRS="/etc/profiles/per-user/$USER/share:/run/system-manager/sw/share:/run/current-system/sw/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
profile="/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
if [[ -r $profile ]]; then
  # shellcheck source=/dev/null
  source "$profile"
fi
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
exec uwsm start -F -D Hyprland -- start-hyprland
