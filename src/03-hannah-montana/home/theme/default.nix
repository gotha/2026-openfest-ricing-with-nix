{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (callPackage ../../packages/theme.nix { })
    dejavu_fonts
    liberation_ttf
    noto-fonts-color-emoji
    kdePackages.oxygen-icons
    kdePackages.breeze-icons
    kdePackages.oxygen-sounds
    kdePackages.oxygen
    kdePackages.oxygen.qt5
    kdePackages.breeze
    kdePackages.breeze-gtk
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "DejaVu Sans" ];
      monospace = [ "DejaVu Sans Mono" ];
      serif = [ "DejaVu Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
