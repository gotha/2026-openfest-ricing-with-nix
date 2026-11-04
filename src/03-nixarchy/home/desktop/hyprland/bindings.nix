let
  exec = key: description: command: {
    inherit key description;
    action = "hl.dsp.exec_cmd(${builtins.toJSON command})";
  };
  dispatch = key: description: action: { inherit key description action; };
in
[
  (exec "SUPER + RETURN" "Terminal" "uwsm app -- foot")
  (exec "SUPER + SHIFT + RETURN" "Browser" "uwsm app -- chromium")
  (exec "SUPER + ALT + RETURN" "tmux session" "uwsm app -- foot -e tmux new-session -A -s main")
  (exec "SUPER + SPACE" "Application launcher" "walker")
  (exec "SUPER + ALT + SPACE" "Desktop menu" "nixarchy menu")
  (exec "SUPER + E" "File manager" "uwsm app -- nautilus")
  (exec "SUPER + SHIFT + T" "Activity monitor" "uwsm app -- foot -e btop")
  (exec "SUPER + V" "Clipboard history" "nixarchy clipboard")
  (exec "SUPER + K" "Keyboard shortcuts" "nixarchy shortcuts")
  (exec "SUPER + CTRL + L" "Lock screen" "nixarchy lock")
  (exec "SUPER + SHIFT + N" "Toggle notifications" "nixarchy dnd")
  (exec "SUPER + SHIFT + I" "Toggle idle locking" "nixarchy idle")
  (exec "Print" "Screenshot region" "nixarchy screenshot region")
  (exec "SHIFT + Print" "Screenshot focused window" "nixarchy screenshot window")
  (exec "CTRL + Print" "Screenshot screen" "nixarchy screenshot screen")
  (exec "SUPER + SHIFT + R" "Start/stop recording" "nixarchy record")
  (dispatch "SUPER + Q" "Close window" "hl.dsp.window.close()")
  (dispatch "SUPER + F" "Fullscreen" ''hl.dsp.window.fullscreen({ action = "toggle" })'')
  (dispatch "SUPER + T" "Toggle floating" ''hl.dsp.window.float({ action = "toggle" })'')
]
++ builtins.concatLists (
  map
    (
      direction:
      let
        dir =
          builtins.replaceStrings [ "LEFT" "RIGHT" "UP" "DOWN" ] [ "left" "right" "up" "down" ]
            direction;
      in
      [
        (dispatch "SUPER + ${direction}" "Focus ${direction}" ''hl.dsp.focus({ direction = "${dir}" })'')
        (dispatch "SUPER + SHIFT + ${direction}" "Swap ${direction}"
          ''hl.dsp.window.swap({ direction = "${dir}" })''
        )
      ]
    )
    [
      "LEFT"
      "RIGHT"
      "UP"
      "DOWN"
    ]
)
++ builtins.concatLists (
  builtins.genList (
    i:
    let
      n = toString (i + 1);
    in
    [
      (dispatch "SUPER + ${n}" "Workspace ${n}" ''hl.dsp.focus({ workspace = "${n}" })'')
      (dispatch "SUPER + SHIFT + ${n}" "Move to workspace ${n}"
        ''hl.dsp.window.move({ workspace = "${n}", follow = true })''
      )
    ]
  ) 9
)
++ [
  (exec "XF86AudioRaiseVolume" "Volume up" "swayosd-client --output-volume raise")
  (exec "XF86AudioLowerVolume" "Volume down" "swayosd-client --output-volume lower")
  (exec "XF86AudioMute" "Mute output" "swayosd-client --output-volume mute-toggle")
  (exec "XF86AudioMicMute" "Mute microphone" "swayosd-client --input-volume mute-toggle")
  (exec "XF86MonBrightnessUp" "Brightness up" "swayosd-client --brightness raise")
  (exec "XF86MonBrightnessDown" "Brightness down" "swayosd-client --brightness lower")
  (exec "XF86AudioPlay" "Play/pause" "playerctl play-pause")
  (exec "XF86AudioNext" "Next track" "playerctl next")
  (exec "XF86AudioPrev" "Previous track" "playerctl previous")
]
