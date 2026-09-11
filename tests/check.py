#!/usr/bin/env python3
"""Non-destructive checks; no display session, sudo or system package changes."""
import ast
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import re
import subprocess
import tempfile
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
QML = ROOT / 'config/quickshell/hshell'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded

for file in ROOT.rglob('*.sh'):
    subprocess.run(['bash', '-n', str(file)], check=True)
for file in ROOT.rglob('*.py'):
    ast.parse(file.read_text(), filename=str(file))
print('PASS: Bash and Python syntax')

style = (QML / 'Style.qml').read_text()
styles = set(re.findall(r'property \w+ (\w+):', style))
for file in QML.rglob('*.qml'):
    text = file.read_text()
    assert not re.search(r'\b(?:Theme|AppearanceState|TodoPanel|CapturePanel|CaptureSelector|Notch)\b', text), file
    assert set(re.findall(r'\bStyle\.(\w+)', text)) <= styles, file
    for imp in re.findall(r'^import "([^"]+)"', text, re.M):
        assert (file.parent / imp).exists(), (file, imp)
    # Structural sanity only; this is not a QML compiler.
    cleaned = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/', '', text)
    assert cleaned.count('{') == cleaned.count('}'), file
for color in re.findall(r'#[0-9a-f]{6}', style):
    assert color[1:3] == color[3:5] == color[5:7]
state = (QML / 'ShellState.qml').read_text()
widths = set(re.findall(r'"(\w+)":', state.split('panelHeights')[0]))
island = (QML / 'Island.qml').read_text()
for panel in widths:
    assert f'"{panel}":' in island, panel
    assert f'window.displayedPanel === "{panel}"' in island, panel
entries = json.loads((QML / 'Utilities.qml').read_text().split('readonly property var entries: ', 1)[1].split('\n    function run', 1)[0])
for entry in entries:
    if entry['kind'] == 'panel': assert entry['value'] in widths, entry
    if entry['kind'] == 'script': assert (ROOT / 'config/scripts' / entry['value']).is_file(), entry
script_refs = re.findall(r'script\("([^"]+)"\)', (ROOT / 'config/hypr/hyprland.lua').read_text())
assert all((ROOT / 'config/scripts' / name).is_file() for name in script_refs)
print('PASS: Removed-feature, monochrome, panel, import and script reference checks')

install = module('hshell_install', ROOT / 'installer/install-config.py')
wallpaper = module('hshell_wallpaper', ROOT / 'config/scripts/wallpaper.py')
with tempfile.TemporaryDirectory(prefix='hshell-check-') as folder:
    temp = Path(folder)
    source = temp / 'repo'
    (source / 'config/quickshell/hshell').mkdir(parents=True)
    (source / 'config/hypr').mkdir(parents=True)
    (source / 'config/scripts').mkdir(parents=True)
    (source / 'examples').mkdir()
    (source / 'examples/local-personal.lua').write_text('personal')
    (source / 'config/hypr/hyprland.lua').write_text('new config')
    (source / 'config/quickshell/hshell/shell.qml').write_text('new shell')
    (source / 'config/quickshell/shell.qml').write_text('stale repo entry')
    (source / 'config/scripts/run.sh').write_text('#!/bin/bash\n')
    (source / 'main.png').write_bytes(b'wallpaper fixture')
    for name in ['alice', 'user with spaces']:
        home = temp / name
        config = home / 'custom config'
        state_dir = home / 'custom state'
        (config / 'hypr').mkdir(parents=True)
        (config / 'quickshell').mkdir()
        (config / 'hypr/hyprland.lua').write_text('old config')
        (config / 'hypr/local.lua').write_text('existing hardware')
        (config / 'quickshell/shell.qml').write_text('old shell')
        (config / 'unrelated.conf').write_bytes(b'\x00untouched\xff')
        with contextlib.redirect_stdout(io.StringIO()):
            copied, backup = install.deploy(source, home, config, state_dir)
        assert (config / 'hypr/hyprland.lua').read_text() == 'new config'
        assert (backup / 'config/hypr/hyprland.lua').read_text() == 'old config'
        assert (backup / 'config/quickshell/shell.qml').read_text() == 'old shell'
        assert not (config / 'quickshell/shell.qml').exists()
        assert (config / 'hypr/local.lua').read_text() == 'existing hardware'
        assert (config / 'unrelated.conf').read_bytes() == b'\x00untouched\xff'
        assert (home / 'Pictures/Wallpapers/main.png').is_file()
        assert (config / 'scripts/run.sh').stat().st_mode & 0o111
        with contextlib.redirect_stdout(io.StringIO()):
            install.deploy(source, home, config, state_dir, personal=True)
        assert (config / 'hypr/local.lua').read_text() == 'personal'
    print('PASS: Two user paths, custom XDG directories, backups, repeated install and personal overrides')
    wallpaper.ROOT = temp / 'Pictures/Wallpapers'
    wallpaper.STATE = temp / 'state'
    wallpaper.ROOT.mkdir(parents=True)
    files = [wallpaper.ROOT / 'winter #1 ü.png', wallpaper.ROOT / "quote's $photo.jpg"]
    for file in files: file.write_bytes(b'fixture')
    (wallpaper.ROOT / 'readme.txt').write_text('not an image')
    assert len(wallpaper.wallpapers()) == 2
    assert wallpaper.check_path(str(files[0])) == files[0]
    try:
        wallpaper.check_path(str(temp / 'outside.png'))
        raise AssertionError('Outside path accepted')
    except ValueError: pass
    with patch.object(wallpaper.subprocess, 'run') as run:
        run.return_value.returncode = 0
        wallpaper.apply(files[1])
        assert run.call_args.args[0] == ['awww', 'img', str(files[1])]
        assert (wallpaper.STATE / 'current-wallpaper').read_text() == str(files[1])
    with patch.object(wallpaper.sys, 'argv', ['wallpaper.py', 'restore-wallpaper']), patch.object(wallpaper, 'apply') as apply:
        wallpaper.main()
        apply.assert_called_once_with(files[1])
    files[1].unlink()
    with patch.object(wallpaper.sys, 'argv', ['wallpaper.py', 'restore-wallpaper']), patch.object(wallpaper, 'apply') as apply:
        wallpaper.main()
        apply.assert_called_once_with(files[0])
    files[0].unlink()
    with patch.object(wallpaper.sys, 'argv', ['wallpaper.py', 'restore-wallpaper']), patch.object(wallpaper.subprocess, 'run') as run:
        run.return_value.returncode = 0
        wallpaper.main()
        assert run.call_args.args[0] == ['awww', 'clear', '000000']
print('PASS: Wallpaper special characters, saved selection, missing-file fallback and empty folder')
print('NOT RUN: QML compilation/rendering, Hyprland runtime, real pacman installation and LightDM login')
