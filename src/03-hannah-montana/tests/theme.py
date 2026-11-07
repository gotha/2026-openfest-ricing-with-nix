"""Validate the installed theme IDs and paths, including the corrected splash."""
import configparser
import json
from pathlib import Path
import struct
import sys

theme, login = map(Path, sys.argv[1:])
share = theme / "share"
look = share / "plasma/look-and-feel/com.decacagle.hml"
metadata = json.loads((look / "metadata.json").read_text())
assert metadata["KPlugin"]["Id"] == look.name
assert not metadata.get("X-KPackage-Dependencies"), "Theme would invoke an online dependency installer"
defaults = configparser.ConfigParser()
defaults.read(look / "contents/defaults")
assert defaults["KSplash"]["Theme"] == look.name
assert (look / "contents/splash/Splash.qml").is_file()
assert (look / "contents/splash/images/hannah-montana.png").is_file()
assert (share / "plasma/desktoptheme/hannah-montana-theme/metadata.json").is_file()
assert (share / "color-schemes/PrettyPink.colors").is_file()
colors = configparser.ConfigParser()
colors.read(share / "color-schemes/HannahMontanaPink.colors")
assert colors["General"]["ColorScheme"] == defaults["kdeglobals][General"]["ColorScheme"]
assert {"Colors:Window", "Colors:Selection", "Colors:Header", "WM"} <= set(colors.sections())
icons = configparser.ConfigParser(strict=False)
icons.read(share / "icons/HannahMontana/index.theme")
assert "oxygen" in icons["Icon Theme"]["Inherits"].split(",")
wallpaper = share / "wallpapers/HannahMontanaTheme/contents/images/1920x1080.png"
image = wallpaper.read_bytes()
assert image[:8] == b"\x89PNG\r\n\x1a\n"
assert struct.unpack(">II", image[16:24]) == (1920, 1080)
for root in (theme, login):
    broken = [str(path) for path in root.rglob("*") if path.is_symlink() and not path.exists()]
    assert not broken, broken
greeter = login / "share/sddm/themes/hannah-montana"
assert (greeter / "background.png").resolve() == wallpaper.resolve()
assert (greeter / "logo.png").is_file()
assert "QtVersion=6" in (greeter / "metadata.desktop").read_text()
print("Theme IDs, wallpaper, icon inheritance, SDDM assets, and symlinks passed.")
