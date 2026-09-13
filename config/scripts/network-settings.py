#!/usr/bin/env python3
import json,re,subprocess,sys
from pathlib import Path
DNS={'dhcp':('',''),'cloudflare':('1.1.1.1,1.0.0.1','2606:4700:4700::1111,2606:4700:4700::1001'),'google':('8.8.8.8,8.8.4.4','2001:4860:4860::8888,2001:4860:4860::8844')}
def run(args):return subprocess.check_output(args,text=True,stderr=subprocess.PIPE).strip()
def profiles():
    rows=[]
    for line in run(['nmcli','-t','-f','UUID,TYPE,DEVICE','connection','show','--active']).splitlines():
        uuid,kind,device=line.split(':',2)
        if kind not in ['802-3-ethernet','802-11-wireless','ethernet','wifi']:continue
        name=run(['nmcli','-g','connection.id','connection','show','uuid',uuid])
        dns=run(['nmcli','-g','ipv4.dns','connection','show','uuid',uuid])
        ignore=run(['nmcli','-g','ipv4.ignore-auto-dns','connection','show','uuid',uuid])
        preset='dhcp' if ignore=='no' and not dns else 'custom'
        for key,value in DNS.items():
            if key!='dhcp' and ignore=='yes' and dns.replace(' ','')==value[0]:preset=key
        rows.append(dict(uuid=uuid,device=device,name=name,preset=preset,dns=dns))
    return rows

def main(action,*args):
    message=''
    if action=='dns':
        uuid,preset=args
        if preset not in DNS or not re.fullmatch(r'[0-9a-fA-F-]{36}',uuid):raise ValueError('Invalid DNS choice')
        row=next((r for r in profiles() if r['uuid']==uuid),None)
        if not row:raise ValueError('Connection is no longer active')
        v4,v6=DNS[preset];ignore='no' if preset=='dhcp' else 'yes'
        run(['nmcli','connection','modify','uuid',uuid,'ipv4.ignore-auto-dns',ignore,'ipv4.dns',v4,'ipv6.ignore-auto-dns',ignore,'ipv6.dns',v6])
        result=subprocess.run(['nmcli','device','reapply',row['device']],capture_output=True,text=True)
        message='DNS Applied' if result.returncode==0 else 'DNS Saved. Reconnect this connection to apply.'
    elif action=='firewall':
        if args[0] not in ['on','off']:raise ValueError('Invalid firewall state')
        run(['pkexec','/usr/bin/ufw','--force','enable' if args[0]=='on' else 'disable'])
        message='Firewall Enabled' if args[0]=='on' else 'Firewall Disabled'
    elif action!='status':raise ValueError('Unknown network setting')
    try: enabled=bool(re.search(r'^ENABLED=yes\s*$',Path('/etc/ufw/ufw.conf').read_text(),re.M))
    except OSError: enabled=False
    return {'connections':profiles(),'firewall':enabled,'message':message}
if __name__=='__main__':
    try:print(json.dumps({'type':'result','data':main(*sys.argv[1:])}),flush=True)
    except Exception as e:print(json.dumps({'type':'error','data':str(e)}),flush=True);sys.exit(1)
