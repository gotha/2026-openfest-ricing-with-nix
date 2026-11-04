usage() {
  cat <<'HELP'
Usage: nixarchy COMMAND
  menu                         Desktop settings and session menu
  clipboard                    Pick an entry from clipboard history
  screenshot [region|window|screen]
  record                       Start a region recording, or stop the current one
  record-status                Waybar recording status as JSON
  idle                         Toggle the idle daemon
  idle-status                  Waybar idle status as JSON
  dnd                          Toggle do-not-disturb notifications
  lock                         Lock the current graphical session
  shortcuts                    Show the actual declared keyboard shortcuts
  theme                        Show the current theme settings
HELP
}

choose() { walker --dmenu; }
notify() { notify-send 'Nixarchy' "$@"; }

screenshot() {
  local mode=${1:-region} geometry image_dir image
  image_dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
  mkdir -p "$image_dir"
  image="$image_dir/$(date +%Y-%m-%d_%H-%M-%S-%N).png"
  case "$mode" in
    region)
      geometry=$(slurp) || return 0
      grim -g "$geometry" - | satty --filename - --output-filename "$image" --copy-command wl-copy
      ;;
    window)
      geometry=$(hyprctl -j activewindow | jq -er 'select(.at and .size) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"') || return 0
      grim -g "$geometry" - | satty --filename - --output-filename "$image" --copy-command wl-copy
      ;;
    screen) grim - | satty --filename - --output-filename "$image" --copy-command wl-copy ;;
    *) usage >&2; return 2 ;;
  esac
}

record() {
  local geometry video_dir video state
  state="${XDG_RUNTIME_DIR:?A local graphical session is required}/nixarchy-recording-path"
  exec 9>"$XDG_RUNTIME_DIR/nixarchy-record.lock"
  flock -n 9 || return 0
  if systemctl --user is-active --quiet nixarchy-record.service; then
    systemctl --user stop nixarchy-record.service
    if [[ -f $state ]]; then
      notify "Recording saved to $(cat "$state")"
      rm -f "$state"
    fi
    return 0
  fi
  geometry=$(slurp) || return 0
  video_dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
  mkdir -p "$video_dir"
  video="$video_dir/$(date +%Y-%m-%d_%H-%M-%S-%N).mp4"
  systemd-run --user --unit=nixarchy-record --collect \
    --property=KillSignal=SIGINT --property=TimeoutStopSec=15s \
    --property=PartOf=graphical-session.target --service-type=exec \
    -- "$(command -v wf-recorder)" -g "$geometry" -f "$video"
  printf '%s\n' "$video" > "$state"
  notify 'Recording started. Press Super+Shift+R to stop.'
}

menu() {
  local choice
  choice=$(printf '%s\n' 'Applications' 'Appearance' 'Sound' 'Network' 'Bluetooth' 'Clipboard' 'Screenshot' 'Recording' 'Keyboard shortcuts' 'Session') || return 0
  choice=$(printf '%s\n' "$choice" | choose) || return 0
  case "$choice" in
    Applications) walker ;;
    Appearance)
      choice=$(printf '%s\n' 'Theme details' 'Reload wallpaper' 'Toggle idle locking' 'Toggle notifications' | choose) || return 0
      case "$choice" in
        'Theme details') theme ;;
        'Reload wallpaper') systemctl --user restart nixarchy-wallpaper.service ;;
        'Toggle idle locking') toggle_idle ;;
        'Toggle notifications') makoctl mode -t do-not-disturb ;;
      esac
      ;;
    Sound) pavucontrol ;;
    Network) nm-connection-editor ;;
    Bluetooth) blueman-manager ;;
    Clipboard) clipboard ;;
    Screenshot) screenshot region ;;
    Recording) record ;;
    'Keyboard shortcuts') foot --title='Nixarchy shortcuts' -e less "$NIXARCHY_SHORTCUTS" ;;
    Session)
      choice=$(printf '%s\n' 'Lock' 'Suspend' 'Log out' 'Reboot' 'Power off' | choose) || return 0
      case "$choice" in
        Lock) lock ;;
        Suspend) systemctl suspend ;;
        'Log out'|'Reboot'|'Power off')
          [[ $(printf '%s\n' Cancel Confirm | choose) == Confirm ]] || return 0
          case "$choice" in
            'Log out') uwsm stop ;;
            Reboot) systemctl reboot ;;
            'Power off') systemctl poweroff ;;
          esac
          ;;
      esac
      ;;
  esac
}

clipboard() {
  local selected
  selected=$(cliphist list | choose) || return 0
  [[ -n $selected ]] || return 0
  printf '%s\n' "$selected" | cliphist decode | wl-copy
}

toggle_idle() {
  if systemctl --user is-active --quiet hypridle.service; then
    systemctl --user stop hypridle.service
    notify 'Automatic idle locking paused for this session.'
  else
    systemctl --user start hypridle.service
    notify 'Automatic idle locking enabled.'
  fi
}

lock() {
  if ! pgrep -u "$(id -u)" -x hyprlock >/dev/null; then
    hyprlock --immediate
  fi
}

theme() {
  # These environment variables are expanded by the child Bash process.
  # shellcheck disable=SC2016
  foot --title='Nixarchy appearance' -e bash -c '
    printf "%s\n\nEdit home/theme/palette.nix and rebuild to change the palette.\n\n" "$NIXARCHY_THEME"
    gum style --foreground 4 "$NIXARCHY_FONT / dark GTK / Bibata cursor"
    read -r -p "Press Enter to close. "
  '
}

case "${1:---help}" in
  --help|-h|help) usage ;;
  menu) menu ;;
  clipboard) clipboard ;;
  screenshot) screenshot "${2:-region}" ;;
  record) record ;;
  record-status)
    if systemctl --user is-active --quiet nixarchy-record.service; then
      jq -cn '{text:"● REC", class:"recording", tooltip:"Click to stop recording"}'
    else
      jq -cn '{text:"", tooltip:"No recording"}'
    fi
    ;;
  idle) toggle_idle ;;
  idle-status)
    if systemctl --user is-active --quiet hypridle.service; then
      jq -cn '{text:"󰒲", tooltip:"Idle locking enabled"}'
    else
      jq -cn '{text:"󰅶", class:"inhibited", tooltip:"Idle locking paused; click to enable"}'
    fi
    ;;
  dnd) makoctl mode -t do-not-disturb ;;
  lock) lock ;;
  shortcuts) foot --title='Nixarchy shortcuts' -e less "$NIXARCHY_SHORTCUTS" ;;
  theme) theme ;;
  *) usage >&2; exit 2 ;;
esac
