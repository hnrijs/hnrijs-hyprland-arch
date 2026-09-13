#!/usr/bin/env python3
"""User-level desktop and terminal defaults; never edits /usr/bin."""
import json,os,subprocess
from pathlib import Path
CONFIG=Path(os.environ.get('XDG_CONFIG_HOME',str(Path.home()/'.config')))
DATA=Path(os.environ.get('XDG_DATA_HOME',str(Path.home()/'.local/share')))
def main():
    apps=DATA/'applications'; apps.mkdir(parents=True,exist_ok=True)
    desktop='[Desktop Entry]\nType=Application\nName=Neovim (Alacritty)\nExec=alacritty -e nvim -- %F\nTerminal=false\nIcon=nvim\nCategories=Utility;TextEditor;\nMimeType=text/plain;text/x-python;application/json;application/x-shellscript;\n'
    # Shadow the system nvim launcher too, so Open With never depends on xterm.
    import shutil,time
    for filename,extra in [('hshell-nvim.desktop','NoDisplay=true\n'),('nvim.desktop','')]:
        target=apps/filename
        if target.exists() and target.read_text()!=desktop+extra:
            backup=Path(os.environ.get('XDG_STATE_HOME',str(Path.home()/'.local/state')))/'hshell/backups'/time.strftime('%Y%m%d-%H%M%S')/filename
            backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(target,backup)
        if target.is_symlink(): target.unlink()
        target.write_text(desktop+extra)

    defaults=json.loads((CONFIG/'applications/defaults.json').read_text())
    candidates=[p.name for base in [apps,Path('/usr/share/applications')] for p in base.glob('*helium*.desktop')]
    if candidates: defaults['browser']=sorted(candidates,key=lambda x:('beta' in x,x))[0]
    (CONFIG/'applications/defaults.json').write_text(json.dumps(defaults,indent=2))
    groups={
        'browser':['x-scheme-handler/http','x-scheme-handler/https','text/html'],
        'video':['video/mp4','video/x-matroska','video/webm','video/quicktime','audio/mpeg','audio/flac','audio/ogg'],
        'image':['image/png','image/jpeg','image/webp','image/gif','image/bmp','image/tiff'],
        'files':['inode/directory'],
        'text':['text/plain','text/x-python','text/x-c','text/x-c++','application/json','application/x-shellscript','text/markdown','text/x-lua','application/x-yaml']}
    for key,mimes in groups.items():
        name=defaults[key]
        if not isinstance(name,str) or not name.endswith('.desktop') or '/' in name: raise ValueError('Use a desktop filename for '+key)
        if not any((base/name).is_file() for base in [apps,Path('/usr/share/applications'),Path('/usr/local/share/applications')]):
            raise FileNotFoundError('Application desktop entry not found: '+name)
        subprocess.run(['xdg-mime','default',name,*mimes],check=True)
    subprocess.run(['update-desktop-database',str(apps)],check=True)
    print('Default apps updated. Neovim uses the Alacritty.')
if __name__=='__main__':main()
