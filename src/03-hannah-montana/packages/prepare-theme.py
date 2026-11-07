"""Resolve the upstream theme's dependencies from the packaged assets."""
import json
from pathlib import Path
import sys

share = Path(sys.argv[1]) / "share"
theme = share / "plasma/look-and-feel/com.decacagle.hml"
metadata_path = theme / "metadata.json"
metadata = json.loads(metadata_path.read_text())
# Every dependency is installed in this package; never invoke an online installer.
metadata.pop("X-KPackage-Dependencies", None)
metadata_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n")
defaults = theme / "contents/defaults"
defaults.write_text(defaults.read_text().replace("Theme=org.hml", "Theme=com.decacagle.hml")
                    .replace("ColorScheme=PrettyPink", "ColorScheme=HannahMontanaPink"))
splash = theme / "contents/splash/Splash.qml"
splash.write_text(splash.read_text().replace('color: "black"', 'color: "#4b1468"')
                  .replace('source: "images/plasma.svgz"', 'source: "images/hannah-montana.png"'))
index = share / "icons/HannahMontana/index.theme"
index.write_text(index.read_text().replace("Inherits=breeze,hicolor", "Inherits=oxygen,breeze,hicolor"))
