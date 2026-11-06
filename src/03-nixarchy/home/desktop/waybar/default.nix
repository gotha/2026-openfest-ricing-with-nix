{ pkgs, ... }:
let
  t = import ../../theme/palette.nix;
in
{
  programs.waybar = {
    enable = true;
    # Waybar 0.15 predates Hyprland's Lua dispatch protocol.
    package = pkgs.waybar.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/Alexays/Waybar/commit/e17c0d9f0a73acc370df60ec8c532b1ed2385c73.patch";
          # The scrolling code in this patch was added after the pinned release.
          excludes = [ "src/modules/hyprland/workspaces.cpp" ];
          hash = "sha256-QsPcxs6B8YPIPE3IzBuxER+12Ur+3JoshouDm/3T3xE=";
        })
      ];
    });
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 8;
      modules-left = [
        "custom/menu"
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "custom/recording"
        "custom/idle"
        "tray"
        "pulseaudio"
        "network"
        "battery"
      ];
      "custom/menu" = {
        format = " 󱄅 ";
        tooltip = false;
        on-click = "nixarchy menu";
      };
      "hyprland/workspaces" = {
        format = "{name}";
        persistent-workspaces."*" = [
          1
          2
          3
          4
          5
        ];
      };
      "hyprland/window".max-length = 40;
      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };
      tray = {
        spacing = 10;
        icon-size = 16;
      };
      pulseaudio = {
        format = " {volume}%";
        format-muted = "󰝟 muted";
        on-click = "pavucontrol";
        on-click-right = "swayosd-client --output-volume mute-toggle";
      };
      network = {
        format-wifi = " {essid}";
        format-ethernet = "󰈀 wired";
        format-disconnected = "󰖪 offline";
        tooltip-format = "{ipaddr}";
        on-click = "nm-connection-editor";
      };
      battery = {
        format = "{icon} {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
        states = {
          warning = 25;
          critical = 10;
        };
      };
      "custom/recording" = {
        exec = "nixarchy record-status";
        return-type = "json";
        interval = 2;
        on-click = "nixarchy record";
      };
      "custom/idle" = {
        exec = "nixarchy idle-status";
        return-type = "json";
        interval = 5;
        on-click = "nixarchy idle";
      };
    };
    style = ''
      * { font-family: "${t.font}", "Font Awesome 7 Free"; font-size: 13px; min-height: 0; border: none; border-radius: 0; }
      window#waybar { background: #${t.background}; color: #${t.foreground}; }
      #workspaces button { color: #${t.muted}; padding: 0 8px; }
      #workspaces button.active { color: #${t.blue}; background: #${t.surface}; border-bottom: 2px solid #${t.blue}; }
      #workspaces button:hover { background: #${t.surface}; box-shadow: none; }
      #clock { color: #${t.blue}; }
      #custom-menu { color: #${t.blue}; font-size: 18px; }
      #pulseaudio, #network, #battery, #tray, #custom-idle, #custom-recording { padding: 0 8px; }
      #battery.critical, #custom-recording.recording { color: #${t.red}; }
      #custom-idle.inhibited { color: #${t.yellow}; }
      tooltip { background: #${t.surface}; color: #${t.foreground}; }
    '';
  };
}
