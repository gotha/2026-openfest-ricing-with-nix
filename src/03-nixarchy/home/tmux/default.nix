{
  config,
  lib,
  pkgs,
  ...
}:
let
  t = import ../theme/palette.nix;
in
{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
      sessionist
      vim-tmux-navigator
      yank
      copycat
      resurrect
    ];
    extraConfig = builtins.readFile ./tmux.conf + ''
      set -g status-style 'bg=#${t.background},fg=#${t.foreground}'
      set -g status-left '#[bg=#${t.blue},fg=#${t.background},bold] #S #[default] '
      set -g window-status-current-style 'bg=#${t.surface},fg=#${t.blue},bold'
      set -g pane-border-style 'fg=#${t.muted}'
      set -g pane-active-border-style 'fg=#${t.blue}'
    '';
  };
  home.packages = [ pkgs.git ];
  # Keep the previous examples' entry point so an old ~/.tmux.conf cannot mask
  # the Home Manager configuration in the XDG location.
  home.file.".tmux.conf".text =
    "source-file ${lib.escapeShellArg "${config.xdg.configHome}/tmux/tmux.conf"}\n";
}
