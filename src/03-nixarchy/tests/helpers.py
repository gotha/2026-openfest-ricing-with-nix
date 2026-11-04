"""Exercise desktop actions without opening a GUI or changing the host session."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

SCRIPT = Path(sys.argv[1]).resolve()

MOCK = """#!PYTHON
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ['MOCK_LOG'], 'a') as log:
    log.write(json.dumps([name, args]) + '\\n')
if name == 'slurp':
    if os.environ.get('CANCEL_CAPTURE') == '1': sys.exit(1)
    print('10,20 640x480')
elif name == 'systemctl':
    if 'is-active' in args: sys.exit(0 if os.environ.get('RECORDING') == '1' else 3)
elif name == 'walker':
    sys.stdin.read()
    queue = Path(os.environ['MOCK_QUEUE'])
    items = json.loads(queue.read_text())
    if not items: sys.exit(1)
    print(items.pop(0))
    queue.write_text(json.dumps(items))
elif name == 'cliphist':
    if args == ['list']: print('42\\ttext with spaces')
    elif args == ['decode']:
        assert sys.stdin.read() == '42\\ttext with spaces\\n'
        print('decoded clipboard', end='')
elif name == 'wl-copy':
    Path(os.environ['MOCK_CLIPBOARD']).write_text(sys.stdin.read())
elif name == 'pgrep': sys.exit(1)
""".replace("PYTHON", sys.executable)


def run(args, selections=(), **settings):
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        commands = root / "bin"
        commands.mkdir()
        mock = commands / "mock"
        mock.write_text(MOCK)
        mock.chmod(0o755)
        for name in ["slurp", "grim", "satty", "systemctl", "systemd-run", "walker",
                     "cliphist", "wl-copy", "notify-send", "hyprlock", "pgrep", "uwsm", "flock", "wf-recorder"]:
            (commands / name).symlink_to(mock)
        log, queue, clipboard = root / "log", root / "queue", root / "clipboard"
        queue.write_text(json.dumps(list(selections)))
        environment = dict(os.environ, PATH=f"{commands}:{os.environ['PATH']}",
                           HOME=str(root), XDG_RUNTIME_DIR=str(root),
                           MOCK_LOG=str(log), MOCK_QUEUE=str(queue),
                           MOCK_CLIPBOARD=str(clipboard), **settings)
        result = subprocess.run(["bash", "-euo", "pipefail", str(SCRIPT), *args],
                                env=environment, capture_output=True, text=True)
        calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
        copied = clipboard.read_text() if clipboard.exists() else None
        return result, calls, copied


result, calls, _ = run(["screenshot", "region"], CANCEL_CAPTURE="1")
assert result.returncode == 0, result.stderr
assert [call[0] for call in calls] == ["slurp"], calls

result, calls, copied = run(["clipboard"], ["42\ttext with spaces"])
assert result.returncode == 0, result.stderr
assert copied == "decoded clipboard", copied

result, calls, _ = run(["record"], RECORDING="1")
assert result.returncode == 0, result.stderr
assert ["systemctl", ["--user", "stop", "nixarchy-record.service"]] in calls, calls
assert all(call[0] not in ["systemd-run", "slurp"] for call in calls), calls

result, calls, _ = run(["record"], CANCEL_CAPTURE="1")
assert result.returncode == 0, result.stderr
assert all(call[0] != "systemd-run" for call in calls), calls

result, calls, _ = run(["record"])
assert result.returncode == 0, result.stderr
started = [args for command, args in calls if command == "systemd-run"]
assert len(started) == 1 and "--property=KillSignal=SIGINT" in started[0], calls
assert "--property=PartOf=graphical-session.target" in started[0], calls
assert started[0][started[0].index("--") + 1].endswith("/wf-recorder"), calls

result, calls, _ = run(["menu"], ["Session", "Reboot", "Cancel"])
assert result.returncode == 0, result.stderr
assert all(command != "systemctl" for command, _ in calls), calls

result, calls, _ = run(["unknown-command"])
assert result.returncode == 2 and not calls, (result.stderr, calls)
print("Seven desktop helper checks passed.")
