#!/usr/bin/env python3
"""Offline regression checks; no package install, desktop session or network access."""
import ast,importlib.util,json,os,re,subprocess,tempfile,unittest,sys
sys.dont_write_bytecode=True
from pathlib import Path
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
QML=ROOT/'config/quickshell/hshell'

def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    if spec is None:
        from importlib.machinery import SourceFileLoader
        spec=importlib.util.spec_from_loader(name,SourceFileLoader(name,str(path)))
    value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value

def duplicate_bindings(text):
    # Ignore quoted strings/comments. Track each QML object independently of JS blocks.
    tokens=re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/|[A-Za-z_][\w.]*|\n|[^\s]',text)
    tokens=[t for t in tokens if not t.startswith(('//','/*'))]
    stack=[];errors=[]
    for i,t in enumerate(tokens):
        if t=='{':
            before=tokens[i-1] if i else ''
            stack.append({} if re.fullmatch(r'[A-Z][\w.]*',before) else None)
        elif t=='}':
            if stack:stack.pop()
        elif t==':' and i and stack and stack[-1] is not None:
            name=tokens[i-1]
            # Only property bindings; excludes the JS conditional operator.
            if re.fullmatch(r'[a-zA-Z_][\w.]*',name) and (i<2 or tokens[i-2] in ['{','}',';','\n']):
                if name in stack[-1]:errors.append(name)
                stack[-1][name]=True
    return errors

class Checks(unittest.TestCase):
    def test_shell_syntax(self):
        for p in [ROOT/'install.sh',*ROOT.glob('config/scripts/*.sh')]:
            with self.subTest(file=p.name):subprocess.run(['bash','-n',str(p)],check=True)
    def test_python_syntax(self):
        for p in ROOT.rglob('*.py'):ast.parse(p.read_text(),filename=str(p))
    def test_no_duplicate_bindings(self):
        # The original brightness regression must be detected by this check.
        self.assertEqual(duplicate_bindings('Item { enabled: true; enabled: false }'),['enabled'])
        self.assertEqual(duplicate_bindings('Item {\n enabled: true\n enabled: false\n}'),['enabled'])
        for p in QML.rglob('*.qml'):
            with self.subTest(file=p.name):self.assertEqual(duplicate_bindings(p.read_text()),[])
        slider=(QML/'panels/ControlPanel.qml').read_text().split('id: brightnessSlider',1)[1].split('onMoved:',1)[0]
        self.assertEqual(slider.count('enabled:'),1)
    def test_removed_features(self):
        for name in ['NotesState.qml','panels/QuickNotesPanel.qml','panels/TodoPanel.qml','panels/CapturePanel.qml']:
            self.assertFalse((QML/name).exists())
        install=(ROOT/'install.sh').read_text()
        for forbidden in ['firefox','gimp','krita','--personal','chmod 666','/usr/bin/xterm']:
            self.assertNotIn(forbidden,install)
        self.assertIn('systemctl set-default graphical.target',install)
        lua=(ROOT/'config/hypr/hyprland.lua').read_text()
        for forbidden in ['DP-3','NVD_BACKEND','session-start.sh','pavucontrol','btop','local.lua']:
            self.assertNotIn(forbidden,lua)
    def test_deploy_portable_and_backup(self):
        deploy=module('deploy',ROOT/'installer/install-config.py')
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);home=base/'another user';config=home/'custom-config';state=home/'custom-state'
            old=config/'quickshell/hshell/obsolete.qml';old.parent.mkdir(parents=True);old.write_text('old shell')
            unrelated=config/'unrelated.ini';unrelated.write_text('keep')
            files,backup=deploy.deploy(ROOT,home,config,state)
            self.assertFalse(old.exists());self.assertEqual((backup/'config/quickshell/hshell/obsolete.qml').read_text(),'old shell')
            self.assertEqual(unrelated.read_text(),'keep')
            self.assertTrue((config/'quickshell/hshell/shell.qml').is_file())
            self.assertTrue((home/'Pictures/Wallpapers').is_dir())
            self.assertTrue(os.access(config/'scripts/screen-search.sh',os.X_OK))
    def test_wallpaper_path_boundary(self):
        wall=module('wall',ROOT/'config/scripts/wallpaper.py')
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);wall.ROOT=base/'Pictures/Wallpapers';wall.ROOT.mkdir(parents=True)
            good=wall.ROOT/'space and ü.png';good.write_bytes(b'picture')
            outside=base/'private.png';outside.write_bytes(b'private')
            self.assertEqual(wall.check_path(str(good)),good)
            with self.assertRaises(ValueError):wall.check_path(str(outside))
    def test_privileged_helper_restricts_inputs(self):
        helper=module('login_helper',ROOT/'installer/polkit/set-login-wallpaper')
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp);good=base/'good.png';good.write_bytes(b'\x89PNG\r\n\x1a\nabc')
            self.assertEqual(helper.read_png(str(good),os.getuid()),good.read_bytes())
            with self.assertRaises(ValueError):helper.read_png(str(good),os.getuid()+1)
            link=base/'link';link.symlink_to(good)
            with self.assertRaises(OSError):helper.read_png(str(link),os.getuid())
            text=base/'not.png';text.write_text('not an image')
            with self.assertRaises(ValueError):helper.read_png(str(text),os.getuid())
    def test_untrusted_args_are_not_shell(self):
        task=module('task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp,patch.object(task,'run_job',return_value={}) as job:
            url='https://example.org/file?x=$(touch%20PWNED)&a=1'
            task.download('file',url,tmp)
            args=job.call_args.args[0]
            self.assertEqual(args[-1],url);self.assertEqual(args[-2],'--')
            with self.assertRaises(ValueError):task.checked_url('file:///etc/passwd')
            with self.assertRaises(ValueError):task.overview('focus-window','0x123;bad')
    def test_preferences_and_invalid_theme(self):
        task=module('prefs_task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp:
            task.STATE=Path(tmp);task.PREFS=task.STATE/'preferences.json'
            task.save_pref('theme','nord');task.save_pref('city','Rīga')
            self.assertEqual(task.prefs()['theme'],'nord');self.assertEqual(task.prefs()['city'],'Rīga')
            with self.assertRaises(ValueError):task.save_pref('theme','not-a-theme')

if __name__=='__main__':unittest.main(verbosity=2)
