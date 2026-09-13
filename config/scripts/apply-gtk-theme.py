#!/usr/bin/env python3
import configparser
from datetime import datetime
import os
from pathlib import Path
import re
import shutil
import subprocess


def apply(home, config, state):
    backup = state / 'hshell/backups' / datetime.now().strftime('%Y%m%d-%H%M%S-%f') / 'gtk'
    def save(path, text):
        if path.exists() or path.is_symlink():
            backup.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, backup / (path.parent.name + '-' + path.name), follow_symlinks=False)
            if path.is_symlink(): path.unlink()
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
    path = config / 'gtk-3.0/settings.ini'
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    if path.is_file(): parser.read(path)
    if not parser.has_section('Settings'): parser.add_section('Settings')
    parser['Settings']['gtk-theme-name'] = 'Materia-dark'
    parser['Settings']['gtk-application-prefer-dark-theme'] = 'true'
    import io
    output = io.StringIO(); parser.write(output)
    save(path, output.getvalue())
    path = home / '.gtkrc-2.0'
    existing = path.read_text() if path.is_file() else ''
    existing = re.sub(r'^\s*gtk-theme-name\s*=.*\n?', '', existing, flags=re.M)
    save(path, existing.rstrip() + '\ngtk-theme-name="Materia-dark"\n')
    if shutil.which('gsettings'):
        subprocess.run(['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme', 'Materia-dark'], check=False, stderr=subprocess.DEVNULL)
        subprocess.run(['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme', 'prefer-dark'], check=False, stderr=subprocess.DEVNULL)


if __name__ == '__main__':
    home = Path.home()
    apply(home, Path(os.environ.get('XDG_CONFIG_HOME', str(home / '.config'))), Path(os.environ.get('XDG_STATE_HOME', str(home / '.local/state'))))
