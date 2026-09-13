import json
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
    def test_usb_transitions(self):
        usb=module('usb_monitor',ROOT/'config/scripts/usb-monitor.py')
        known={}
        event={'DEVTYPE':'usb_device','DEVPATH':'/devices/test','ACTION':'add','ID_MODEL':'Flash_Drive'}
        self.assertEqual(usb.consume(event,known)['body'],'Flash Drive')
        self.assertIsNone(usb.consume(event,known))
        event['ACTION']='remove';event.pop('ID_MODEL')
        self.assertEqual(usb.consume(event,known)['body'],'Flash Drive')
        self.assertIsNone(usb.consume(event,known))
    def test_central_navigation(self):
        state=(QML/'ShellState.qml').read_text()
        self.assertIn('setPanel("tool")',state)
        self.assertIn('setPanel("detail")',state)
        self.assertIn('interval: 1000',state)
        self.assertFalse((QML/'panels/SidePanel.qml').exists())
        choice=(QML/'components/Choice.qml').read_text()
        self.assertNotIn('Popup.Window',choice)
        self.assertIn('root.currentIndex = index',choice)
        lua=(ROOT/'config/hypr/hyprland.lua').read_text()
        self.assertIn('bezier = "hshell"',lua)
        self.assertNotIn('curve = "hshell"',lua)
    def test_history_retention_and_clear(self):
        task=module('history_task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp:
            task.STATE=Path(tmp)
            for i in range(35):task.history('history-add','speed',json.dumps({'download':i}))
            data=task.history();self.assertEqual(len(data['speed']),30)
            self.assertEqual(data['speed'][0]['download'],34)
            task.history('history-add','colors',json.dumps({'color':'#89B4FA'}))
            data=task.history('history-clear','speed')
            self.assertEqual(data['speed'],[]);self.assertEqual(len(data['colors']),1)
            with self.assertRaises(ValueError):task.history('history-add','colors',json.dumps({'color':'bad'}))
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
    def test_sddm_and_materia(self):
        installer=(ROOT/'install.sh').read_text()
        self.assertIn('sddm.service',installer)
        self.assertNotIn('lightdm',installer.lower())
        self.assertIn('materia-gtk-theme',installer)
        wallpaper=(ROOT/'config/scripts/wallpaper.py').read_text()
        self.assertNotIn('pkexec',wallpaper)
        self.assertNotIn('syncLogin',(QML/'panels/SettingsPanel.qml').read_text())

    def test_untrusted_args_are_not_shell(self):
        task=module('task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp,patch.object(task,'run_job',return_value={}) as job:
            url='https://example.org/file?x=$(touch%20PWNED)&a=1'
            task.download('file',url,tmp)
            args=job.call_args.args[0]
            self.assertEqual(args[-1],url);self.assertEqual(args[-2],'--')
            with self.assertRaises(ValueError):task.checked_url('file:///etc/passwd')
            with self.assertRaises(ValueError):task.overview('focus-window','0x123;bad')
    def test_preferences_validation(self):
        task=module('prefs_task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp:
            task.STATE=Path(tmp);task.PREFS=task.STATE/'preferences.json'
            task.save_pref('visualizer','false');task.save_pref('city','Rīga')
            self.assertEqual(task.prefs()['visualizer'],'false');self.assertEqual(task.prefs()['city'],'Rīga')
            with self.assertRaises(ValueError):task.save_pref('theme','not-a-theme')

    def test_clipboard_copies_without_paste(self):
        with tempfile.TemporaryDirectory() as tmp:
            d=Path(tmp)
            for name,body in [('cliphist','printf "test clipboard"'),('wl-copy','cat > "$XDG_RUNTIME_DIR/copied"'),('hyprctl','exit 99')]:
                p=d/name;p.write_text('#!/bin/bash\n'+body+'\n');p.chmod(0o755)
            env=dict(os.environ,PATH=str(d)+':'+os.environ['PATH'],XDG_RUNTIME_DIR=str(d))
            subprocess.run(['bash',str(ROOT/'config/scripts/shell-actions.sh'),'clipboard-paste','3'],env=env,check=True)
            self.assertEqual((d/'copied').read_text(),'test clipboard')
    def test_power_cycle_debounces_duplicates(self):
        with tempfile.TemporaryDirectory() as tmp:
            d=Path(tmp);p=d/'powerprofilesctl'
            p.write_text('#!/bin/bash\ncase "$1" in get) echo balanced ;; list) printf "  performance:\n* balanced:\n  power-saver:\n" ;; set) echo "$2" >> "$XDG_RUNTIME_DIR/changes" ;; esac\n');p.chmod(0o755)
            env=dict(os.environ,PATH=str(d)+':'+os.environ['PATH'],XDG_RUNTIME_DIR=str(d))
            for _ in range(2):subprocess.run(['bash',str(ROOT/'config/scripts/shell-actions.sh'),'power-profile-cycle'],env=env,check=True)
            self.assertEqual((d/'changes').read_text().splitlines(),['power-saver'])
    def test_exif_preserves_original(self):
        task=module('exif_task',ROOT/'config/scripts/hshell-task.py')
        with tempfile.TemporaryDirectory() as tmp:
            source=Path(tmp)/'photo.jpg';source.write_bytes(b'original')
            with patch.object(task.subprocess,'run') as run:
                result=task.exif('remove',str(source))
                self.assertEqual(source.read_bytes(),b'original')
                self.assertNotEqual(result['path'],str(source))
                self.assertEqual(run.call_args.args[0][-1],result['path'])
    def test_full_emoji_dataset(self):
        source=(QML/'Emoji.qml').read_text();raw=source.split('entries:',1)[1].rsplit('}',1)[0].strip()
        entries=json.loads(raw)
        self.assertGreater(len(entries),3900)
        self.assertEqual(len(entries),len({e[0] for e in entries}))
        self.assertTrue(any('Latvia' in e[1] for e in entries))

    def test_materia_preserves_gtk_settings(self):
        gtk=module('gtk_apply',ROOT/'config/scripts/apply-gtk-theme.py')
        with tempfile.TemporaryDirectory() as tmp:
            home=Path(tmp);config=home/'config';state=home/'state'
            folder=config/'gtk-3.0';folder.mkdir(parents=True)
            (folder/'settings.ini').write_text('[Settings]\ngtk-theme-name=Previous\ngtk-font-name=User Font 12\n')
            with patch.object(gtk.shutil,'which',return_value=None):gtk.apply(home,config,state)
            data=(folder/'settings.ini').read_text()
            self.assertIn('Materia-dark',data);self.assertIn('User Font 12',data)
            self.assertTrue(list(state.rglob('gtk-3.0-settings.ini')))

if __name__=='__main__':unittest.main(verbosity=2)
