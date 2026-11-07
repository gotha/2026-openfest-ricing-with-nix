{ pkgs, ... }:
let
  kde = pkgs.kdePackages;
  desktop = pkgs.buildEnv {
    name = "hannah-montana-plasma";
    paths = with kde; [
      plasma-desktop
      plasma-workspace
      kwin
      kscreen
      kscreenlocker
      kactivitymanagerd
      kde-cli-tools
      kglobalacceld
      kded
      kauth
      kcoreaddons
      kfilemetadata
      kpackage
      kservice
      kio
      kio-extras
      kio-fuse
      knighttime
      kwallet
      kwalletmanager
      systemsettings
      powerdevil
      plasma-nm
      plasma-pa
      plasma-activities
      solid
      polkit-kde-agent-1
      milou
      kdeplasma-addons
      frameworkintegration
      plasma-integration
      kde-gtk-config
      libplasma
      kcmutils
      kguiaddons
      kiconthemes
      kimageformats
      qqc2-desktop-style
      qqc2-breeze-style
      oxygen
      oxygen.qt5
      breeze
      breeze.qt5
      breeze-icons
      breeze-gtk
      qtwayland
      qtsvg
      qtimageformats
      xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-utils
      pkgs.xdg-user-dirs
      pkgs.xwayland
      pkgs.dconf
    ];
    pathsToLink = [
      "/bin"
      "/libexec"
      "/share"
      "/etc/xdg"
      "/${kde.qtbase.qtPluginPrefix}"
      "/${kde.qtbase.qtQmlPrefix}"
      "/${pkgs.qt5.qtbase.qtPluginPrefix}"
      "/${pkgs.qt5.qtbase.qtQmlPrefix}"
    ];
    ignoreCollisions = true;
  };
  session = pkgs.writeShellApplication {
    name = "hannah-montana-session";
    runtimeInputs = [
      pkgs.systemd
      pkgs.dbus
    ];
    excludeShellChecks = [ "SC1091" ];
    text = ''
      . ${../../home/plasma/session-env.sh}
      export PATH="/run/wrappers/bin:${desktop}/bin:$PATH"
      export XDG_DATA_DIRS="${desktop}/share:$XDG_DATA_DIRS"
      export XDG_CONFIG_DIRS="${desktop}/etc/xdg:''${XDG_CONFIG_DIRS:-/etc/xdg}"
      export QT_PLUGIN_PATH="${desktop}/${kde.qtbase.qtPluginPrefix}:${desktop}/${pkgs.qt5.qtbase.qtPluginPrefix}"
      export QML2_IMPORT_PATH="${desktop}/${kde.qtbase.qtQmlPrefix}:${desktop}/${pkgs.qt5.qtbase.qtQmlPrefix}"
      export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
      export QT_QPA_PLATFORMTHEME=kde
      export TZDIR=${pkgs.tzdata}/share/zoneinfo
      export XDG_CURRENT_DESKTOP=KDE XDG_SESSION_DESKTOP=KDE XDG_SESSION_TYPE=wayland
      export DESKTOP_SESSION=hannah-montana XDG_MENU_PREFIX=plasma-
      # A previous graphical session may have left these in the user environment.
      unset DISPLAY WAYLAND_DISPLAY
      systemctl --user daemon-reload
      exec ${kde.plasma-workspace}/bin/startplasma-wayland
    '';
  };
  hostIntegration = pkgs.runCommand "hannah-montana-plasma-host" { } ''
    mkdir -p "$out/lib/tmpfiles.d"
    rules="$out/lib/tmpfiles.d/hannah-montana-plasma.conf"
    touch "$rules"
    # Polkit's native daemon reads actions from /usr/share, not XDG_DATA_DIRS.
    for policy in ${desktop}/share/polkit-1/actions/*.policy; do
      test -f "$policy" || continue
      printf 'L+ /usr/share/polkit-1/actions/%s - - - - %s\n' \
        "$(basename "$policy")" "$policy" >> "$rules"
    done
  '';
in
{
  inherit desktop session hostIntegration;
}
