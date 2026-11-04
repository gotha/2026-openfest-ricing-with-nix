{ pkgs, ... }:
let
  t = import ../../theme/palette.nix;
in
{
  services.elephant = {
    enable = true;
    settings = {
      launch_prefix = "uwsm app --";
      terminal_cmd = "foot";
    };
    # Compiling only these providers also excludes the clipboard recorder.
    package = pkgs.elephant.override {
      enabledProviders = [
        "desktopapplications"
        "runner"
        "files"
        "calc"
      ];
    };
  };
  services.walker = {
    enable = true;
    systemd.enable = true;
    enableElephantIntegration = true;
    settings = {
      providers = {
        default = [
          "desktopapplications"
          "calc"
        ];
        empty = [ "desktopapplications" ];
        prefixes = [
          {
            prefix = ">";
            provider = "runner";
          }
          {
            prefix = "/";
            provider = "files";
          }
          {
            prefix = "=";
            provider = "calc";
          }
        ];
      };
    };
  };
  # Override the built-in layout's CSS while retaining its packaged XML layout.
  xdg.configFile."walker/themes/default/style.css".text = ''
    * { font-family: "${t.font}"; font-size: 15px; color: #${t.foreground}; }
    .box-wrapper { background: #${t.background}; border: 2px solid #${t.blue}; border-radius: 10px; padding: 18px; }
    .search-container { background: #${t.surface}; border-radius: 6px; padding: 8px; }
    .input { background: transparent; border: none; box-shadow: none; }
    .item-box { padding: 8px; border-radius: 5px; }
    .item-box:selected, .item:selected { background: #${t.surface}; color: #${t.blue}; }
    .item-subtext { color: #${t.muted}; }
  '';
}
