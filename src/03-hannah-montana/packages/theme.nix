{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  python3,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "hannah-montana-theme";
  version = "2026-06-15";
  src = fetchFromGitLab {
    owner = "DecaCagle";
    repo = "hannah-montana-kde-theme";
    rev = "87dcb860d289c88dffdba92f8443e3e4091b20cb";
    hash = "sha256-q15fZnVzEoTkA6/kOI2j/WE//wD4WTUSCF/rdOiuelY=";
  };
  nativeBuildInputs = [ python3 ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/plasma/look-and-feel" "$out/share/plasma/desktoptheme" \
      "$out/share/color-schemes" "$out/share/icons" "$out/share/wallpapers" \
      "$out/share/doc/hannah-montana-theme"
    cp -r --no-preserve=mode,ownership look-and-feel/com.decacagle.hml "$out/share/plasma/look-and-feel/"
    cp -r --no-preserve=mode,ownership plasma-style/hannah-montana-theme "$out/share/plasma/desktoptheme/"
    cp color-scheme/PrettyPink.colors "$out/share/color-schemes/"
    cp -r --no-preserve=mode,ownership icons/HannahMontana "$out/share/icons/"
    cp -r --no-preserve=mode,ownership wallpaper/HannahMontanaTheme "$out/share/wallpapers/"
    cp icons/HannahMontana/places/start-here-kde.png "$out/share/icons/hannah-montana-logo.png"
    cp icons/HannahMontana/places/start-here-kde.png \
      "$out/share/plasma/look-and-feel/com.decacagle.hml/contents/splash/images/hannah-montana.png"
    cp LICENSE README.md "$out/share/doc/hannah-montana-theme/"
    python3 ${./prepare-theme.py} "$out"
    runHook postInstall
  '';
  meta = {
    description = "Hannah Montana Plasma theme, icons, colors, wallpaper, and splash";
    homepage = "https://gitlab.com/DecaCagle/hannah-montana-kde-theme";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
