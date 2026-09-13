#!/usr/bin/env python3
import json,os,re,subprocess,sys,time
from pathlib import Path
STATE=Path(os.environ.get('XDG_STATE_HOME',str(Path.home()/'.local/state')))/'hshell'

def calculate(expression,refresh=False):
    if not expression.strip() or len(expression)>2000 or '\n' in expression:raise ValueError('Enter one expression')
    expression=re.sub(r'%\s+of\s+', '/100 * ',expression,flags=re.I)
    expression=expression.replace('°C','celsius').replace('°F','fahrenheit')
    expression=re.sub(r'\bdegC\b','celsius',expression)
    expression=re.sub(r'\bdegF\b','fahrenheit',expression)
    command=['qalc','--defaults','-t','-m','5000','-s','color 0','-s','update exchange rates 0']
    warning=''
    refreshed=False
    if refresh:
        try:
            update=subprocess.run(command+['--exrates','1'],stdin=subprocess.DEVNULL,capture_output=True,text=True,timeout=25)
            refreshed=update.returncode==0
            if not refreshed: warning='Rate refresh failed or was incomplete. Using cached rates.'
        except subprocess.TimeoutExpired: warning='Rate refresh timed out. Using cached rates.' 
    # A leading blank prevents a negative expression from becoming a CLI option.
    result=subprocess.run(command+[' '+expression],stdin=subprocess.DEVNULL,capture_output=True,text=True,timeout=30,env=dict(os.environ,LC_ALL='C.UTF-8'))
    if result.returncode or not result.stdout.strip():raise ValueError(result.stderr.strip() or result.stdout.strip() or 'Calculation failed')
    if refreshed:
        STATE.mkdir(parents=True,exist_ok=True);(STATE/'calculator-rates-date').write_text(time.strftime('%Y-%m-%d'))
    try:stamp=(STATE/'calculator-rates-date').read_text().strip()
    except OSError:stamp='Cached Rates — Refresh for Recent Rates'
    return {'text':result.stdout.strip(),'ratesDate':stamp,'warning':warning or result.stderr.strip()}
if __name__=='__main__':
    try:print(json.dumps({'type':'result','data':calculate(sys.argv[1],len(sys.argv)>2 and sys.argv[2]=='refresh')}))
    except Exception as e:print(json.dumps({'type':'error','data':str(e)}));sys.exit(1)
