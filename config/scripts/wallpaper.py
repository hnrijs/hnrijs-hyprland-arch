#!/usr/bin/env python3
"""Wallpaper selection for hshell; no GTK or desktop recoloring."""
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path.home() / "Pictures" / "Wallpapers"
STATE = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "hshell"
EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif"}


def wallpapers():
    ROOT.mkdir(parents=True, exist_ok=True)
    return sorted((p for p in ROOT.rglob("*") if p.is_file() and p.suffix.lower() in EXTENSIONS),
                  key=lambda p: str(p.relative_to(ROOT)).casefold())


def check_path(raw):
    path = Path(raw).expanduser().absolute()
    # Resolve the parent to reject traversal, but allow image symlinks inside the folder.
    if not path.parent.resolve().is_relative_to(ROOT.resolve()):
        raise ValueError("Choose an image inside ~/Pictures/Wallpapers")
    if not path.is_file() or path.suffix.lower() not in EXTENSIONS:
        raise ValueError("Wallpaper is missing or has an unsupported extension")
    return path


def ready():
    for _ in range(30):
        result = subprocess.run(["awww", "query"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            return
        time.sleep(0.1)
    raise RuntimeError("awww-daemon is not ready; start it before selecting a wallpaper")


def apply(path, sync_login=False):
    ready()
    subprocess.run(["awww", "img", "--transition-type", "none", str(path)], check=True)
    STATE.mkdir(parents=True, exist_ok=True)
    temporary = STATE / "current-wallpaper.tmp"
    temporary.write_text(str(path), encoding="utf-8")
    temporary.replace(STATE / "current-wallpaper")
    # Convert untrusted image formats as the desktop user, never inside the root helper.
    import tempfile
    with tempfile.TemporaryDirectory(prefix="wallpaper-",dir=STATE) as work:
        image=Path(work)/"wallpaper.png"
        subprocess.run(["magick",str(path)+"[0]","-resize","3840x2160>","-strip","PNG:"+str(image)],check=True)
        import shutil
        shutil.copyfile(image,STATE/"wallpaper.png")
        if sync_login:
            subprocess.run(["pkexec","/usr/lib/hshell/set-login-wallpaper",str(image)],check=True)



def main():
    command = sys.argv[1] if len(sys.argv) > 1 else "wallpapers"
    if command == "wallpapers":
        print(json.dumps([{"path": str(p), "name": p.name, "url": p.as_uri()} for p in wallpapers()]))
    elif command == "open-wallpapers":
        ROOT.mkdir(parents=True, exist_ok=True)
        subprocess.run(["thunar", str(ROOT)], check=True)
    elif command == "wallpaper" and len(sys.argv) == 3:
        try:
            settings=json.loads((STATE/"preferences.json").read_text())
        except (OSError,ValueError): settings={}
        apply(check_path(sys.argv[2]),settings.get("syncLogin","true") not in ("false",False))
    elif command == "restore-wallpaper":
        try:
            selected = check_path((STATE / "current-wallpaper").read_text(encoding="utf-8"))
        except (OSError, ValueError):
            entries = wallpapers()
            selected = ROOT / "main.png" if (ROOT / "main.png").is_file() else (entries[0] if entries else None)
        if selected:
            apply(selected)
        else:
            ready()
            subprocess.run(["awww", "clear", "000000"], check=True)
    else:
        raise ValueError("Unknown wallpaper command")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
