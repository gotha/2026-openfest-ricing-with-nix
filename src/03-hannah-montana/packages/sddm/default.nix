{ pkgs, lib, ... }:
let
  theme = pkgs.callPackage ../theme.nix { };
in
pkgs.runCommand "hannah-montana-sddm-theme"
  {
    meta = {
      description = "Hannah Montana login theme for Qt 6 SDDM";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
  ''
    destination="$out/share/sddm/themes/hannah-montana"
    mkdir -p "$destination"
    cp ${./Main.qml} "$destination/Main.qml"
    cp ${./metadata.desktop} "$destination/metadata.desktop"
    ln -s ${theme}/share/wallpapers/HannahMontanaTheme/contents/images/1920x1080.png "$destination/background.png"
    ln -s ${theme}/share/icons/hannah-montana-logo.png "$destination/logo.png"
  ''
