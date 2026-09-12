#!/usr/bin/env python3
"""Deploy repository config files, backing up only destinations we replace."""
import argparse
from datetime import datetime
from pathlib import Path
import shutil


def deploy(source, home, config, state):
    stamp = datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    backup = state / 'hshell' / 'backups' / stamp
    copied = []
    def copy_file(src, dst, label):
        if dst.exists() or dst.is_symlink():
            old = backup / label
            old.parent.mkdir(parents=True, exist_ok=True)
            if dst.is_dir():
                raise RuntimeError(f'Expected a file, found directory: {dst}')
            shutil.copy2(dst, old, follow_symlinks=False)
            # Do not write through a destination symlink into another checkout.
            if dst.is_symlink():
                dst.unlink()
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        copied.append(dst)
    for folder in ['Documents', 'Music', 'Downloads', 'Pictures/Wallpapers', 'Videos']:
        (home / folder).mkdir(parents=True, exist_ok=True)
    # Flat root shell.qml from the previous config can mask named configurations.
    old_entry = config / 'quickshell' / 'shell.qml'
    if old_entry.exists():
        saved = backup / 'config/quickshell/shell.qml'
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(old_entry), saved)
    old_shell = config / 'quickshell/hshell'
    if old_shell.exists() or old_shell.is_symlink():
        saved = backup / 'config/quickshell/hshell'
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(old_shell), saved)
    incoming = source / 'config' 
    for item in sorted(incoming.rglob('*')):
        if item.is_file():
            relative = item.relative_to(incoming)
            if "__pycache__" in relative.parts or item.suffix == ".pyc": continue
            if relative.parts[0] == 'quickshell' and relative.parts[1] != 'hshell':
                continue
            # All shipped scripts are portable; do not rewrite unrelated files with sed.
            copy_file(item, config / relative, Path('config') / relative)
    main = source / 'main.png'
    if main.is_file():
        copy_file(main, home / 'Pictures/Wallpapers/main.png', Path('wallpapers/main.png'))
    walls = source / 'Wallpapers'
    if walls.is_dir():
        for item in sorted(walls.rglob('*')):
            if item.is_file():
                relative = item.relative_to(walls)
                copy_file(item, home / 'Pictures/Wallpapers' / relative, Path('wallpapers') / relative)
    for item in (config / 'scripts').glob('*'):
        if item.is_file() and item.suffix in {'.sh', '.py'}:
            item.chmod(item.stat().st_mode | 0o111)
    print(f'Installed {len(copied)} files into {config}')
    if backup.exists():
        print(f'Backups: {backup}')
    return copied, backup


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--home', type=Path, required=True)
    parser.add_argument('--config', type=Path, required=True)
    parser.add_argument('--state', type=Path, required=True)
    args = parser.parse_args()
    deploy(args.source, args.home, args.config, args.state)
