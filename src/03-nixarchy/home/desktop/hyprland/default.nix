{ lib, ... }:
let
  t = import ../../theme/palette.nix;
  bindings = import ./bindings.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    # UWSM manages the session targets and environment on both backends.
    systemd.enable = false;
    settings = {
      config = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          col.active_border = "rgb(${t.blue})";
          col.inactive_border = "rgb(${t.surface})";
        };
        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 4;
            passes = 2;
          };
          shadow = {
            enabled = true;
            range = 12;
            render_power = 3;
            color = "rgba(00000040)";
          };
        };
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      };
      window_rule = [
        {
          match.class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor)$";
          float = true;
        }
        {
          match.class = "^(satty)$";
          float = true;
        }
      ];
      bind =
        map (b: {
          _args = [
            b.key
            (lib.generators.mkLuaInline b.action)
            {
              description = b.description;
              repeating = lib.hasInfix "Volume" b.key || lib.hasInfix "Brightness" b.key;
              locked = lib.hasPrefix "XF86" b.key;
            }
          ];
        }) bindings
        ++ [
          {
            _args = [
              "SUPER + mouse:272"
              (lib.generators.mkLuaInline "hl.dsp.window.drag()")
              { mouse = true; }
            ];
          }
          {
            _args = [
              "SUPER + mouse:273"
              (lib.generators.mkLuaInline "hl.dsp.window.resize()")
              { mouse = true; }
            ];
          }
        ];
      on._args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
                  hl.exec_cmd("uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP")
                end'')
      ];
    };
  };
  xdg.configFile."uwsm/env-hyprland".text = ''
    export NIXOS_OZONE_WL=1
    export XDG_CURRENT_DESKTOP=Hyprland
    export XCURSOR_THEME=Bibata-Modern-Ice
    export XCURSOR_SIZE=24
  '';
}
