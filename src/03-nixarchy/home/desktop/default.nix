{
  lib,
  backend,
  bluetooth ? false,
  ...
}:
{
  imports = [
    ./hyprland
    ./waybar
    ./launcher
    ./session
  ];
  wayland.systemd.target = "graphical-session.target";
  # These services belong to this compositor, including across logouts. Other
  # desktop sessions on the same account keep their own bar and agents.
  systemd.user.services =
    lib.genAttrs
      (
        [
          "waybar"
          "walker"
          "elephant"
          "mako"
          "swayosd"
          "hypridle"
          "cliphist"
          "polkit-gnome"
          "network-manager-applet"
          "nixarchy-wallpaper"
        ]
        ++ lib.optional bluetooth "blueman-applet"
      )
      (_: {
        Unit = {
          ConditionEnvironment = lib.mkForce [
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP=Hyprland"
          ];
          PartOf = [ "graphical-session.target" ];
        };
      });
}
