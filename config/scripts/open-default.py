#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys

config = Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config')))
role = sys.argv[1]
if role not in ['browser', 'files']:
    raise SystemExit('Unknown application role')
defaults = json.loads((config / 'applications/defaults.json').read_text())
entry = defaults[role]
if not isinstance(entry, str) or not entry.endswith('.desktop') or '/' in entry or entry.startswith('-'):
    raise SystemExit('Invalid desktop entry')
os.execvp('gtk-launch', ['gtk-launch', entry] + ([str(Path.home())] if role == 'files' else []))
