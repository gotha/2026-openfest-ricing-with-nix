{
  lib,
  pkgs,
  extras ? true,
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
      kdePackages.okular
      kdePackages.gwenview
      kdePackages.ark
      kdePackages.spectacle
      kdePackages.kcalc
      kdePackages.konqueror
      kdePackages.khelpcenter
      firefox
      amarok
      vlc
      libreoffice-fresh
      fastfetch
      # Plasma Manager invokes qdbus; Debian names its Qt 6 executable qdbus6.
      (lib.getBin kdePackages.qttools)
    ]
    ++ lib.optionals extras [
      kdePackages.kontact
      kdePackages.kmail
      kdePackages.akonadi
      kdePackages.kdepim-runtime
      kdePackages.kmail-account-wizard
      # NeoChat at this pin pulls in libolm, which Nixpkgs refuses as insecure.
      fractal
      kdePackages.kolourpaint
      kdePackages.kpat
      kdePackages.kmines
      kdePackages.ksudoku
      kdePackages.k3b
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
      "application/pdf" = [ "org.kde.okular.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "audio/mpeg" = [ "org.kde.amarok.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
