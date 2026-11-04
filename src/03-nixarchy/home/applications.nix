{ pkgs, ... }:
let
  t = import ./theme/palette.nix;
in
{
  home.packages = with pkgs; [
    nautilus
    imv
    evince
    pavucontrol
    pamixer
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    wireplumber
    pipewire
    gnome-keyring
    grim
    slurp
    satty
    wf-recorder
    wl-clipboard
    cliphist
    jq
    gum
    libnotify
    xdg-utils
    xdg-terminal-exec
  ];
  programs.git.enable = true;
  programs.lazygit.enable = true;
  programs.chromium = {
    enable = true;
    commandLineArgs = [ "--ozone-platform=wayland" ];
  };
  programs.mpv.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "nixarchy";
      theme_background = true;
      vim_keys = true;
    };
  };
  xdg.configFile."btop/themes/nixarchy.theme".text = ''
    theme[main_bg]="#${t.background}"
    theme[main_fg]="#${t.foreground}"
    theme[title]="#${t.blue}"
    theme[hi_fg]="#${t.purple}"
    theme[selected_bg]="#${t.surface}"
    theme[selected_fg]="#${t.cyan}"
    theme[inactive_fg]="#${t.muted}"
    theme[graph_text]="#${t.foreground}"
    theme[meter_bg]="#${t.surface}"
    theme[proc_misc]="#${t.purple}"
    theme[cpu_start]="#${t.green}"
    theme[cpu_mid]="#${t.blue}"
    theme[cpu_end]="#${t.red}"
  '';
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "audio/mpeg" = [ "mpv.desktop" ];
      "text/plain" = [ "nvim.desktop" ];
    };
  };
  xdg.configFile."xdg-terminal-exec.list".text = "foot.desktop\n";
}
