{ pkgs, ... }:
let
  t = import ../theme/palette.nix;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${t.font}:size=12";
        pad = "14x14";
        term = "xterm-256color";
      };
      cursor = {
        style = "beam";
        blink = "yes";
      };
      colors-dark = {
        background = t.background;
        foreground = t.foreground;
        regular0 = t.surface;
        regular1 = t.red;
        regular2 = t.green;
        regular3 = t.yellow;
        regular4 = t.blue;
        regular5 = t.purple;
        regular6 = t.cyan;
        regular7 = t.foreground;
        bright0 = t.muted;
        bright1 = t.red;
        bright2 = t.green;
        bright3 = t.yellow;
        bright4 = t.blue;
        bright5 = t.purple;
        bright6 = t.cyan;
        bright7 = "ffffff";
      };
    };
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -lah --git";
      cat = "bat";
      vim = "nvim";
    };
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$character";
      directory.style = "bold #${t.blue}";
      git_branch.style = "#${t.purple}";
      character = {
        success_symbol = "[❯](bold #${t.green})";
        error_symbol = "[❯](bold #${t.red})";
      };
    };
  };
  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };
  programs.eza.enable = true;
  home.packages = with pkgs; [
    ripgrep
    fd
  ];
}
