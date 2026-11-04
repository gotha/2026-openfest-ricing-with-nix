{ pkgs, lib, ... }:
let
  bindings = import ../home/desktop/hyprland/bindings.nix;
  shortcuts = pkgs.writeText "nixarchy-shortcuts.txt" (
    "Nixarchy keyboard shortcuts\n\n"
    + lib.concatMapStrings (b: "${b.key}\t${b.description}\n") bindings
    + "\nCtrl+Space\ttmux prefix\n"
  );
  commands = pkgs.writeShellApplication {
    name = "nixarchy";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      util-linux
      systemd
      jq
      gum
      libnotify
      walker
      wl-clipboard
      cliphist
      uwsm
      bash
      grim
      slurp
      satty
      wf-recorder
      hyprland
      hyprlock
      foot
      less
      mako
      pavucontrol
      networkmanagerapplet
      networkmanager
      blueman
    ];
    text =
      let
        theme = import ../home/theme/palette.nix;
      in
      ''
        export NIXARCHY_SHORTCUTS=${shortcuts}
        export NIXARCHY_THEME=${lib.escapeShellArg theme.name}
        export NIXARCHY_FONT=${lib.escapeShellArg theme.font}
      ''
      + builtins.readFile ./nixarchy.sh;
  };
  session = pkgs.writeShellApplication {
    name = "nixarchy-session";
    runtimeInputs = [
      pkgs.uwsm
      pkgs.hyprland
    ];
    excludeShellChecks = [ "SC1091" ];
    text = builtins.readFile ./session.sh;
  };
in
pkgs.symlinkJoin {
  name = "nixarchy";
  paths = [
    commands
    session
  ];
  meta = {
    description = "Nixarchy desktop commands and session launcher";
    mainProgram = "nixarchy";
    platforms = lib.platforms.linux;
  };
}
