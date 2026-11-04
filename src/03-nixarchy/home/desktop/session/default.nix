{
  lib,
  pkgs,
  backend,
  bluetooth ? false,
  ...
}:
let
  t = import ../../theme/palette.nix;
  wallpaper = pkgs.runCommand "nixarchy-wallpaper.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
    rsvg-convert -o "$out" ${t.wallpaper}
  '';
in
{
  services.mako = {
    enable = true;
    settings = {
      font = "${t.font} 11";
      background-color = "#${t.background}";
      text-color = "#${t.foreground}";
      border-color = "#${t.blue}";
      border-size = 2;
      border-radius = 8;
      padding = "14";
      default-timeout = 6000;
      anchor = "top-right";
      width = 360;
      "mode=do-not-disturb".invisible = true;
    };
  };
  services.cliphist = {
    enable = true;
    allowImages = false;
  };
  services.swayosd.enable = true;
  services.polkit-gnome.enable = true;
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = bluetooth;
  # The host's PAM / D-Bus integration starts the keyring daemon.
  services.gnome-keyring.enable = false;
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 0;
      };
      background = [
        {
          monitor = "";
          path = "${wallpaper}";
          blur_passes = 2;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "320, 55";
          position = "0, -40";
          inner_color = "rgb(${t.surface})";
          outer_color = "rgb(${t.blue})";
          font_color = "rgb(${t.foreground})";
          font_family = t.font;
          placeholder_text = "Password";
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          font_family = t.font;
          color = "rgb(${t.foreground})";
          position = "0, 100";
        }
      ];
    };
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "nixarchy lock";
        before_sleep_cmd = "loginctl lock-session";
        inhibit_sleep = 3;
        after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "nixarchy lock";
        }
        {
          timeout = 600;
          on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' '';
          on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
        }
      ];
    };
  };
  systemd.user.services.nixarchy-wallpaper = {
    Unit = {
      Description = "Nixarchy wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  home.packages = [
    pkgs.swaybg
    pkgs.polkit_gnome
  ];
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };
  xdg.configFile."swayosd/style.css".text = ''
    window { background: #${t.background}; border: 2px solid #${t.blue}; border-radius: 10px; color: #${t.foreground}; }
    progressbar progress { background: #${t.blue}; }
  '';
}
