{
  config,
  pkgs,
  ...
}:
let
  theme = pkgs.callPackage ../../packages/theme.nix { };
  wallpaper = "${theme}/share/wallpapers/HannahMontanaTheme/contents/images/1920x1080.png";
  font = {
    family = "DejaVu Sans";
    pointSize = 10;
  };
in
{
  programs.plasma = {
    enable = true;
    overrideConfig = false;
    workspace = {
      theme = "hannah-montana-theme";
      colorScheme = "PrettyPink";
      iconTheme = "HannahMontana";
      widgetStyle = "Oxygen";
      inherit wallpaper;
      clickItemTo = "open";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      windowDecorations = {
        library = "org.kde.oxygen";
        theme = "Oxygen";
      };
      splashScreen.theme = "com.decacagle.hml";
    };
    fonts = {
      general = font;
      menu = font;
      toolbar = font;
      small = font // {
        pointSize = 9;
      };
      windowTitle = font // {
        weight = "bold";
      };
      fixedWidth = {
        family = "DejaVu Sans Mono";
        pointSize = 10;
      };
    };
    panels = [
      {
        location = "bottom";
        height = 40;
        floating = false;
        hiding = "none";
        lengthMode = "fill";
        widgets = [
          {
            kickoff = {
              icon = "${theme}/share/icons/hannah-montana-logo.png";
              favoritesDisplayMode = "list";
              applicationsDisplayMode = "list";
              sortAlphabetically = true;
            };
          }
          {
            name = "org.kde.plasma.taskmanager";
            config.General.launchers = [
              "applications:firefox.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.amarok.desktop"
            ];
          }
          "org.kde.plasma.pager"
          "org.kde.plasma.systemtray"
          {
            digitalClock = {
              time.format = "24h";
              date.enable = true;
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
    kscreenlocker = {
      autoLock = true;
      timeout = 10;
      lockOnResume = true;
      passwordRequired = true;
      appearance.wallpaper = wallpaper;
    };
    hotkeys.commands."open-konsole" = {
      name = "Open Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };
    shortcuts = {
      "org.kde.krunner.desktop"._launch = [
        "Alt+F2"
        "Alt+Space"
      ];
      "org.kde.spectacle.desktop"._launch = "Print";
      ksmserver."Lock Session" = "Meta+L";
      kwin."Walk Through Windows" = "Alt+Tab";
    };
    configFile = {
      kdeglobals.KDE.LookAndFeelPackage = "com.decacagle.hml";
      kdeglobals.General.TerminalApplication = "konsole";
      kwinrc.Desktops = {
        Number = 4;
        Rows = 1;
      };
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      ksmserverrc.General.loginMode = "emptySession";
      # Keep Klipper in Plasma's own session instead of starting a second daemon.
      klipperrc.General.MaxClipItems = 30;
    };
  };
  programs.konsole = {
    enable = true;
    defaultProfile = "Hannah Montana";
    profiles."Hannah Montana" = {
      colorScheme = "HannahMontana";
      font = {
        name = "DejaVu Sans Mono";
        size = 11;
      };
    };
    customColorSchemes.HannahMontana = {
      General = {
        Description = "Hannah Montana";
        Opacity = 1.0;
        Blur = false;
      };
      Background.Color = "43,14,62";
      Foreground.Color = "255,240,189";
      Color0.Color = "43,14,62";
      Color1.Color = "240,100,135";
      Color2.Color = "166,214,140";
      Color3.Color = "255,212,90";
      Color4.Color = "147,181,255";
      Color5.Color = "231,133,238";
      Color6.Color = "141,217,217";
      Color7.Color = "255,240,189";
    };
  };
  home.file."Desktop/Home.desktop".text = ''
    [Desktop Entry]
    Type=Link
    Name=Home
    Icon=user-home
    URL=file://${config.home.homeDirectory}
  '';
  home.file."Desktop/Trash.desktop".text = ''
    [Desktop Entry]
    Type=Link
    Name=Trash
    Icon=user-trash
    URL=trash:/
  '';
}
