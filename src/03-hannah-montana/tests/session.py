"""Source the Debian startup script without changing a real session."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

script = str(Path(sys.argv[1]).resolve())
for profile_name in (".nix-profile", ".local/state/nix/profile"):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        profile = root / profile_name
        variables = profile / "etc/profile.d/hm-session-vars.sh"
        variables.parent.mkdir(parents=True)
        variables.write_text('export XCURSOR_PATH="/test/icons${XCURSOR_PATH:+:}$XCURSOR_PATH"\nexport PROFILE_LOADED=yes\n')
        env = dict(os.environ, HOME=str(root), USER="hannah-test", XDG_DATA_DIRS="/inherited/share")
        for name in ("XCURSOR_PATH", "QT_PLUGIN_PATH", "QML2_IMPORT_PATH", "QML_IMPORT_PATH", "PROFILE_LOADED", "__HM_SESS_VARS_SOURCED"):
            env.pop(name, None)
        result = subprocess.run(["bash", "-euc", '''
          . "$1"
          test "$PROFILE_LOADED" = yes
          test "$XCURSOR_PATH" = /test/icons
          case $- in *u*) ;; *) exit 1 ;; esac
          for directory in /usr/share /usr/local/share /inherited/share "$HOME/.nix-profile/share"; do
            case ":$XDG_DATA_DIRS:" in *":$directory:"*) ;; *) exit 1 ;; esac
          done
          test -z "${QT_PLUGIN_PATH:-}${QML_IMPORT_PATH:-}${QML2_IMPORT_PATH:-}"
        ''', "test-session", script], env=env, capture_output=True, text=True)
        assert result.returncode == 0, result.stderr
print("Both Home Manager profile locations preserve host data paths and shell options.")
