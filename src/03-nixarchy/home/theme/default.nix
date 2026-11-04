{ lib, pkgs, ... }:
let
  t = import ./palette.nix;
in
{
  home.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    adw-gtk3
    yaru-theme
    bibata-cursors
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ t.font ];
      sansSerif = [ "Noto Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Yaru-dark";
      package = pkgs.yaru-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
  xdg.configFile."nixarchy/palette.json".text = builtins.toJSON (removeAttrs t [ "wallpaper" ]);
}
