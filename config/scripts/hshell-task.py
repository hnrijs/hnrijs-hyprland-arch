#!/usr/bin/env python3
"""JSON-lines helpers for hshell; user input is always passed as argv, never shell code."""
import ipaddress
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
import urllib.parse
import urllib.request

STATE = Path(os.environ.get('XDG_STATE_HOME', str(Path.home()/'.local/state'))) / 'hshell'
SCRIPTS = Path(__file__).resolve().parent
PREFS = STATE/'preferences.json'
BOOL_PREFS = ['visualizer','hoverExpand','mediaCard','tray','notifications','weather','hideFullscreen','workspaceOsd','volumeOsd','showPower','showMic','showIdle','showNightlight','showBluetooth','showWifi']


def emit(kind, data):
    print(json.dumps({'type': kind, 'data': data}, ensure_ascii=False), flush=True)


def prefs():
    try:
        value=json.loads(PREFS.read_text())
        return value if isinstance(value, dict) else {}
    except (OSError, ValueError): return {}


def save_pref(key, value):
    if key not in BOOL_PREFS + ['city','notificationSeconds','wallpaperFolder','backgroundColor','surfaceColor','foregroundColor','accentColor']: raise ValueError('Unknown preference')
    if key in BOOL_PREFS and value not in ['true', 'false']: raise ValueError('Expected true or false')
    if key == 'city' and (not value.strip() or len(value) > 120): raise ValueError('Invalid city')
    if key == 'notificationSeconds' and not 0.1 <= float(value) <= 10: raise ValueError('Duration must be 0.1–10 seconds')
    if key.endswith('Color') and not re.fullmatch(r'#[0-9a-fA-F]{6}',value): raise ValueError('Use a six-digit hex color')
    if key == 'wallpaperFolder':
        value=str(Path(value).expanduser())
        if not Path(value).is_absolute(): raise ValueError('Use an absolute folder path')
        Path(value).mkdir(parents=True,exist_ok=True)
    data=prefs(); data[key]=value
    STATE.mkdir(parents=True, exist_ok=True)
    tmp=PREFS.with_suffix('.tmp'); tmp.write_text(json.dumps(data)); tmp.replace(PREFS)
    return data


def history(action='history', kind='', raw=''):
    import fcntl
    STATE.mkdir(parents=True,exist_ok=True)
    with (STATE/'history.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        path=STATE/'history.json'
        try: data=json.loads(path.read_text())
        except (OSError,ValueError): data={}
        if not isinstance(data,dict): data={}
        for key in ['colors','speed','ip']:
            if not isinstance(data.get(key),list): data[key]=[]
        if action != 'history':
            if kind not in data or kind not in ['colors','speed','ip']: raise ValueError('Unknown history')
            if action=='history-clear': data[kind]=[]
            elif action=='history-add':
                entry=json.loads(raw)
                if not isinstance(entry,dict): raise ValueError('Invalid history entry')
                if kind=='colors' and not re.fullmatch(r'#[0-9a-fA-F]{6}',entry.get('color','')): raise ValueError('Invalid color')
                entry['time']=time.strftime('%Y-%m-%d %H:%M')
                data[kind]=([entry]+data[kind])[:30]
            tmp=path.with_suffix('.tmp');tmp.write_text(json.dumps(data));tmp.replace(path)
        return data


def web_json(url):
    req=urllib.request.Request(url, headers={'User-Agent':'hshell/2.0'})
    with urllib.request.urlopen(req, timeout=20) as response:
        return json.loads(response.read(2_000_000))


def checked_url(value, magnet=False):
    scheme=urllib.parse.urlsplit(value).scheme.lower()
    if scheme not in (['magnet'] if magnet else ['http','https']):
        raise ValueError('Enter a valid '+('magnet' if magnet else 'HTTP(S)')+' URL')
    return value


def path_arg(value):
    if value.startswith('file://'):
        value=urllib.parse.unquote(urllib.parse.urlsplit(value).path)
    path=Path(value).expanduser().absolute()
    if not path.is_file(): raise ValueError('Choose an existing file')
    return path


def run_job(command, label):
    if not shutil.which(command[0]): raise RuntimeError('Required program is missing: '+command[0])
    emit('progress', {'message':label})
    process=subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors='replace', start_new_session=True)
    # The process is owned by this helper. Stop the child if the helper is cancelled.
    import signal
    def stop(signum, frame):
        os.killpg(process.pid,signal.SIGTERM)
        try: process.wait(timeout=5)
        except subprocess.TimeoutExpired: os.killpg(process.pid,signal.SIGKILL)
        raise SystemExit(130)
    signal.signal(signal.SIGTERM, stop)
    for line in process.stdout:
        emit('progress', {'message':line.strip()[-500:]})
    code=process.wait()
    if code: raise RuntimeError(f'{command[0]} exited with code {code}')
    subprocess.run(['notify-send','hshell',label+' completed'], check=False)
    return {'message':label+' completed'}


def download(mode, raw_url, destination, playlist='false'):
    url=checked_url(raw_url, mode=='magnet')
    folder=Path(destination or str(Path.home()/'Downloads')).expanduser().absolute()
    folder.mkdir(parents=True, exist_ok=True)
    stamp=time.strftime('%Y%m%d-%H%M%S')
    commands={
        'mp3':['yt-dlp','--newline','--no-overwrites','-P',str(folder),'-x','--audio-format','mp3'],
        'mp4':['yt-dlp','--newline','--no-overwrites','-P',str(folder),'-S','ext:mp4:m4a','--merge-output-format','mp4'],
        'file':['wget','--no-clobber','--directory-prefix',str(folder),'--content-disposition'],
        'magnet':['aria2c','--seed-time=0','--allow-overwrite=false','--dir',str(folder)],
        'html':['monolith','-o',str(folder/f'page-{stamp}.html')],
        'git':['git','clone',url,str(folder/f'repository-{stamp}')],
    }
    if mode not in commands: raise ValueError('Unknown download type')
    command=commands[mode]
    if mode in ['mp3','mp4']: command += ['--yes-playlist' if playlist=='true' else '--no-playlist']
    if mode!='git': command += ['--',url]
    return run_job(command, 'Download')


def media(mode, raw_file, parameter=''):
    source=path_arg(raw_file)
    stamp=time.strftime('%Y%m%d-%H%M%S')
    output=source.with_name(source.stem+'-'+mode+'-'+stamp+source.suffix)
    command=['ffmpeg','-hide_banner','-nostdin','-n','-i',str(source)]
    if mode=='silent': command+=['-c','copy','-an']
    elif mode=='rotate': command+=['-vf','transpose=1']
    elif mode=='mirror': command+=['-vf','hflip']
    elif mode=='mp3': output=output.with_suffix('.mp3'); command+=['-vn']
    elif mode=='resize':
        if not re.fullmatch(r'[1-9][0-9]{1,4}',parameter): raise ValueError('Enter a width in pixels, e.g. 1920')
        output=output.with_suffix('.mp4'); command+=['-vf','scale='+parameter+':-2']
    elif mode=='trim':
        times=parameter.split()
        if len(times)!=2 or not all(re.fullmatch(r'\d{2}:\d{2}:\d{2}',v) for v in times): raise ValueError('Enter start and duration: 00:00:10 00:00:30')
        command+=['-ss',times[0],'-t',times[1],'-c','copy']
    elif mode=='png':
        output=output.with_suffix('.png'); command=['magick',str(source)]
    else: raise ValueError('Unknown media operation')
    result=run_job(command+[str(output)],'Media job');result['path']=str(output);return result


def exif(mode, raw_file):
    source=path_arg(raw_file)
    if mode=='view':
        data=subprocess.check_output(['exiftool','-j',str(source)],text=True)
        return {'text':json.dumps(json.loads(data),ensure_ascii=False,indent=2)}
    if mode!='remove': raise ValueError('Unknown EXIF action')
    import uuid
    output=source.with_name(source.stem+'-clean-'+uuid.uuid4().hex[:8]+source.suffix)
    shutil.copy2(source, output)
    try:
        subprocess.run(['exiftool','-all=','-overwrite_original',str(output)],check=True,capture_output=True,text=True)
    except Exception:
        output.unlink(missing_ok=True)
        raise
    return {'path':str(output),'message':'Clean copy saved'}


def disks():
    data=json.loads(subprocess.check_output(['lsblk','--json','--bytes','--paths','-o','NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT,TYPE,MODEL'],text=True))
    rows=[]
    def visit(item):
        if item.get('fstype') or item.get('type')=='disk':
            row={k:item.get(k) for k in ['name','label','fstype','size','mountpoint','type','model']}
            if item.get('mountpoint'):
                try:
                    usage=shutil.disk_usage(item['mountpoint']);row.update(total=usage.total,used=usage.used,free=usage.free)
                except OSError: pass
            rows.append(row)
        for child in item.get('children',[]):visit(child)
    for device in data['blockdevices']:visit(device)
    return {'disks':rows}


def speed():
    import speedtest
    emit('progress',{'phase':'Connecting','download':0,'upload':0,'ping':0})
    client=speedtest.Speedtest(secure=True)
    client.get_servers();server=client.get_best_server()
    ping=client.results.ping
    emit('progress',{'phase':'Download','download':0,'upload':0,'ping':ping})
    down=client.download()/1e6
    emit('progress',{'phase':'Upload','download':down,'upload':0,'ping':ping})
    up=client.upload()/1e6
    return {'phase':'Complete','download':down,'upload':up,'ping':ping,'server':server.get('sponsor','')}


def overview(action, *args):
    if action=='windows':
        return {'windows':json.loads(subprocess.check_output(['hyprctl','-j','clients'],text=True))}
    if action=='workspace':
        ws=int(args[0]);assert 1<=ws<=10
        expr=f'hl.dispatch(hl.dsp.focus({{workspace={ws}}}))'
    else:
        address=args[0]
        if not re.fullmatch(r'0x[0-9a-fA-F]+',address):raise ValueError('Invalid window address')
        if action=='move-window':
            ws=int(args[1]);assert 1<=ws<=10
            expr=f'hl.dispatch(hl.dsp.window.move({{workspace={ws},window="address:{address}"}}))'
        elif action=='focus-window':expr=f'hl.dispatch(hl.dsp.focus({{window="address:{address}"}}))'
        else:raise ValueError('Unknown window action')
    subprocess.run(['hyprctl','eval',expr],check=True,stdout=subprocess.DEVNULL)
    return {'message':'Done'}


def main(action, *args):
    if action in ['network-settings','calculate']:
        name='network-settings.py' if action=='network-settings' else 'calculator.py'
        code=subprocess.call([sys.executable,str(SCRIPTS/name),*args])
        raise SystemExit(code)
    if action=='exif':return exif(*args)
    if action=='power-profiles':
        output=subprocess.check_output(['powerprofilesctl','list'],text=True)
        return {'profiles':[p for p in ['power-saver','balanced','performance'] if re.search(r'^\s*\*?\s*'+p+r':',output,re.M)]}
    if action=='preferences':return prefs()
    if action=='preference':return save_pref(*args)
    if action=='weather':
        city=(args[0] if args else 'Riga').strip() or 'Riga'
        data=web_json('https://wttr.in/'+urllib.parse.quote(city,safe='')+'?format=j1')
        now=data['current_condition'][0]
        return {'city':city,'temperature':now['temp_C'],'feels':now['FeelsLikeC'],'humidity':now['humidity'], 'wind':now['windspeedKmph'],'description':now['weatherDesc'][0]['value']}
    if action in ['history','history-add','history-clear']:return history(action,*args)
    if action=='pick-color':
        time.sleep(0.3) # Let the pill release input before the selection overlay starts.
        proc=subprocess.run(['hyprpicker','--format=hex'],capture_output=True,text=True)
        color=proc.stdout.strip()
        if not color:return {'message':'Selection cancelled'}
        if not re.fullmatch(r'#[0-9a-fA-F]{6}',color):raise ValueError('Picker returned an invalid color')
        subprocess.run(['wl-copy','--',color],check=True)
        subprocess.run(['notify-send','hshell','Color copied: '+color],check=False)
        return {'color':color.upper()}
    if action=='ip':
        target=args[0].strip() if args else ''
        if target:ipaddress.ip_address(target)
        data=web_json('https://ipwho.is/'+urllib.parse.quote(target,safe=''))
        if data.get('success') is False:raise ValueError(data.get('message','Lookup failed'))
        return {'ip':data.get('ip'),'city':data.get('city'),'region':data.get('region'),'country':data.get('country'),'isp':data.get('connection',{}).get('isp'),'timezone':data.get('timezone',{}).get('id')}
    if action=='disks':return disks()
    if action in ['mount','unmount']:
        if not re.fullmatch(r'/dev/[A-Za-z0-9_./-]+',args[0]):raise ValueError('Invalid block device')
        run_job(['udisksctl',action,'-b',args[0]],'Disk '+action);return disks()
    if action=='speed':return speed()
    if action=='download':return download(*args)
    if action=='media':return media(*args)
    if action in ['windows','workspace','move-window','focus-window']:return overview(action,*args)
    if action=='clipboard-clear':
        subprocess.run(['cliphist','wipe'],check=True)
        subprocess.run(['wl-copy','--clear'],check=True)
        cache=Path(os.environ['XDG_RUNTIME_DIR'])/'hshell-clipboard'
        if cache.is_dir() and not cache.is_symlink(): shutil.rmtree(cache)
        return {'message':'Clipboard history cleared'}
    if action=='caffeine':
        runtime=Path(os.environ['XDG_RUNTIME_DIR'])/'hshell-caffeine'
        if args and args[0]=='toggle':
            if runtime.exists():runtime.unlink()
            else:runtime.touch()
            subprocess.run(["notify-send", "-a", "hshell", "Idle mode", "Stay awake enabled" if runtime.exists() else "Automatic idle enabled"],check=False)
        return {'enabled':runtime.exists()}
    raise ValueError('Unknown task')

if __name__=='__main__':
    try:emit('result',main(*sys.argv[1:]))
    except Exception as error:
        emit('error',str(error))
        if len(sys.argv)>1 and sys.argv[1] in ['download','media']:
            subprocess.run(['notify-send','hshell',str(error)],check=False)
        sys.exit(1)
