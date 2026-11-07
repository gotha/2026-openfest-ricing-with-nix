{
  lib,
  pkgs,
  backend ? "nixos",
  ...
}:
{
  home.packages =
    with pkgs;
    [
      kdePackages.dolphin
      kdePackages.kio-extras
      kdePackages.kio-fuse
      kdePackages.ffmpegthumbs
      kdePackages.konsole
      kdePackages.kate
      firefox
      vlc
      # Plasma Manager invokes qdbus; Debian names its Qt 6 executable qdbus6.
      (lib.getBin kdePackages.qttools)
    ]
    ++ lib.optionals (backend == "nixos") [
      kdePackages.systemsettings
      kdePackages.kwalletmanager
    ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
      "text/plain" = [ "org.kde.kate.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "audio/mpeg" = [ "vlc.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
