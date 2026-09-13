from pathlib import Path
import shutil,os,tempfile
base=Path(tempfile.mkdtemp(prefix='hshell-ui-')); target=base/'render-v5-imports/qs';shutil.copytree(Path(__file__).resolve().parents[1]/'config/quickshell/hshell',target,dirs_exist_ok=True)
def singleton(name,body): (target/(name+'.qml')).write_text('pragma Singleton\nimport QtQuick\nQtObject {\n'+body+'\n}')
singleton('Preferences','property bool visualizer:true\nproperty bool hoverExpand:true\nproperty bool mediaCard:true\nproperty bool tray:true\nproperty bool notifications:true\nproperty bool weather:true\nproperty bool hideFullscreen:true\nproperty bool workspaceOsd:true\nproperty bool volumeOsd:true\nproperty bool showPower:true\nproperty bool showMic:true\nproperty bool showIdle:true\nproperty bool showNightlight:true\nproperty bool showBluetooth:true\nproperty bool showWifi:true\nproperty string city:"Riga"\nfunction save(k,v){}')
p=target/'Preferences.qml';p.write_text(p.read_text().replace('QtObject {','QtObject {\nproperty real notificationSeconds:3\nproperty string wallpaperFolder:"/home/test/Pictures/Wallpapers"\nproperty string backgroundColor:"#080808"\nproperty string surfaceColor:"#202020"\nproperty string foregroundColor:"#ffffff"\nproperty string accentColor:"#ffffff"',1))
singleton('Cava','property var levels:[20,30,60,30,90,30,50,40,70,20]')
singleton('NotificationCenter','property var current:null;property string screenName:"";function dismissCurrent(){}')
p=target/'Style.qml';p.write_text(p.read_text().replace('import Quickshell','').replace('Singleton {','QtObject {'))
singleton('ShellState','property string panel: "control"\nproperty string toolName:"download"\nproperty string detailName:"wifi"\nproperty int nightLightTemperature:4500\nproperty bool dnd:false\nproperty string leftPanel:""\nproperty string rightPanel:""\nproperty string scripts:"/tmp/"\nproperty var liveNotifications:[]\nproperty var notificationHistory:[{id:1,app:"hshell",summary:"USB connected",body:"SanDisk USB drive"}]\nfunction side(n,d){toolName=n;panel="tool"}\nfunction back(){panel="menu"}\nfunction close(){}\nfunction clearNotifications(){notificationHistory=[]}')
singleton('Controls','property var sink:({description:"Built-in audio",audio:{volume:0.36,muted:false}})\nproperty var source:({audio:{muted:false,volume:0.6}})\nproperty var connectedWifi:({name:"Home Wi-Fi"})\nproperty bool wifiOn:true\nproperty var adapter:({enabled:true})\nproperty var bluetoothDevices:[]\nproperty var wifiNetworks:[]\nproperty var knownWifiNetworks:[]\nproperty var availableWifiNetworks:[]\nproperty var pendingWifiNetwork:null\nproperty var wifiDevice:({})\nproperty string wifiError:""\nproperty var audioSinks:[]\nproperty var audioSources:[]\nproperty var connectedDevices:[]\nproperty bool hasBattery:false\nproperty real batteryLevel:0.8\nproperty int wifiToggles:0\nfunction volume(v){}\nfunction mic(){}\nfunction wifi(){wifiToggles++}\nfunction bluetooth(){}\nfunction mute(){}')
singleton('Backend','property var clipboardItems:[{id:"1",preview:"Copied text example",imageSource:""},{id:"2",preview:"https://wiki.hypr.land/",imageSource:""}]\nproperty string clipboardImageSource:""\nproperty string clipboardContents:""\nproperty bool clipboardContentsLoading:false\nfunction refreshClipboard(){}\nproperty bool brightnessAvailable:true\nproperty int brightness:65\nproperty string powerProfile:"balanced"\nproperty string nightLightStatus:"off"\nfunction setBrightness(v){}\nfunction cyclePowerProfile(){}\nfunction toggleNightLight(){}')
body=''
for name in ['network','caffeine','download','media','exif','ip','speed','disks','clipboard','weather','color']:
 body+=f'property QtObject {name}: QtObject {{ property bool running:false; property var result:({{}}); property var progress:({{}}); property string error:""; function start(a){{}} }}\n'
singleton('Tasks',body)
for name in ['Auth']:
 singleton(name,'property var flow:({message:"Authentication is needed to mount the device",inputPrompt:"Password",actionId:"org.freedesktop.udisks2.filesystem-mount",supplementaryMessage:"",isResponseRequired:true,responseVisible:false})')
singleton('BluetoothPairing','property bool active:false; property string error:""; property string deviceName:""; property var request:({}); function cancel(){} function answer(a,v){}')
singleton('Media','''property QtObject player:QtObject {
property string identity:"Music player"
property string trackTitle:"Sample track"
property string trackArtist:"Artist name"
property string trackArtUrl:""
property bool isPlaying:true
property bool canTogglePlaying:true
property bool canGoPrevious:true
property bool canGoNext:true
property bool canSeek:true
property bool positionSupported:true
property bool lengthSupported:true
property real position:45
property real length:180
function togglePlaying(){} function next(){} function previous(){}
}
function nextPlayer(){}''')
singleton('History','property var entries:({colors:[],speed:[],ip:[]})\nfunction clear(k){}\nfunction reload(){}')
singleton('Quickshell','function env(k){return "/home/test"}\nfunction execDetached(a){}')
singleton('SystemTray','''id:traystub
property int activations:0
property int quits:0
property var items:({values:[{id:"test",title:"Test app",icon:"",onlyMenu:false,
activate:function(){traystub.activations++},menu:{actions:[{enabled:true,text:"Quit",icon:"",triggered:function(){traystub.quits++}}]}}]})''')
(target/'QsMenuOpener.qml').write_text('import QtQuick\nQtObject {property var menu;property var children:({values:menu ? menu.actions : []})}')
singleton('WallpaperState','property var wallpapers:[]\nproperty bool busy:false\nproperty string error:""\nfunction refreshWallpapers(){}')
# Only inactive unrelated service-backed panels are replaced in this layout fixture.
for name in ['LauncherPanel',]:
 (target/'panels'/f'{name}.qml').write_text('import QtQuick\nItem {property string kind:""; property var shellWindow; implicitHeight:100; function takeInitialFocus(){} }')
p=target/'ShellState.qml';p.write_text(p.read_text().replace('QtObject {','QtObject {\nproperty bool externalDialog:false\nfunction dismissInterface(){close()}\nfunction setPanel(n){panel=n}',1))
p=target/'panels/ClipboardPanel.qml';t=p.read_text();a=t.index('model: ScriptModel {');j=t.index('{',a)+1;depth=1
while depth:
 depth+=(t[j]=='{')-(t[j]=='}');j+=1
t=t[:a]+'model: Backend.clipboardItems'+t[j:];t=t.replace('id: root','id: root\nproperty QtObject fixtureModel:QtObject {id:filteredItems;property var values:Backend.clipboardItems}',1);p.write_text(t)
(target/'Task.qml').write_text('import QtQuick\nQtObject { property bool running:false; property var result:({}); property var progress:({}); property string error:""; signal finished(bool success); function start(a){} function cancel(){} }')
for p in target.rglob('*.qml'):
 s=p.read_text();s='\n'.join(l for l in s.splitlines() if not l.startswith('import Quickshell'))
 s=s.replace('Singleton {','QtObject {')
 s=s.replace('model: SystemTray.items','model: SystemTray.items.values')
 p.write_text('import QtQuick\n'+s)
for folder in [target,target/'components',target/'panels']:
 lines=['module '+'.'.join(folder.relative_to(base/'render-v5-imports').parts)]
 for p in folder.glob('*.qml'):
  if p.name=='shell.qml':continue
  lines.append(('singleton ' if 'pragma Singleton' in p.read_text() else '')+p.stem+' 1.0 '+p.name)
 (folder/'qmldir').write_text('\n'.join(lines))
(base/'render-main.qml').write_text('''import QtQuick
import QtQuick.Window
import qs
Window { width:620; height:Math.min(840,panel.implicitHeight); visible:true; color:"#080808"
property int wifiToggles:Controls.wifiToggles
property int trayActivations:SystemTray.activations
property int trayQuits:SystemTray.quits
property string page:"control"
property string tool:"download"
property string detail:"nightlight"
onDetailChanged:ShellState.detailName=detail
onPageChanged: ShellState.panel=page
onToolChanged: ShellState.toolName=tool
PanelContent { id:panel; anchors.fill:parent; shellWindow:null }
}''')
os.environ['QT_QPA_PLATFORM']='offscreen';os.environ['QT_QUICK_BACKEND']='software'
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickWindow
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtTest import QTest
app=QGuiApplication([])
from PySide6.QtGui import QFontDatabase
for font in (Path.cwd()/'preview-fonts').glob('*.ttf'): QFontDatabase.addApplicationFont(str(font))
engine=QQmlApplicationEngine();engine.addImportPath(str(base/'render-v5-imports'));engine.load(str(base/'render-main.qml'))
if not engine.rootObjects():raise SystemExit(1)
root=engine.rootObjects()[0];out=base/'rendered-v5';out.mkdir(exist_ok=True)
for page,tool in [('clipboard',''),('wallpaper',''),('auth',''),('calendar',''),('control',''),('menu',''),('tools',''),('settings',''),('power',''),('color',''),('web',''),('emoji',''),('tool','download'),('tool','speed'),('tool','periodic'),('tool','media'),('tool','exif'),('tool','interface'),('tool','system'),('tool','network'),('tool','calculator')]:
 root.setProperty('width',1040 if tool=='periodic' else 420 if page=='calendar' else 620);root.setProperty('tool',tool);root.setProperty('page',page);QTest.qWait(350);root.grabWindow().save(str(out/(tool or page))+'.png')
from PySide6.QtCore import QObject,QPoint,Qt
def visual_find(item,name):
 if item.objectName()==name:return item
 for child in item.childItems():
  result=visual_find(child,name)
  if result is not None:return result
 return None
for tool,expected in [('download','MP3'),('media','Mute Video')]:
 root.setProperty('tool',tool);root.setProperty('page','tool');QTest.qWait(150)
 choice=root.findChild(QObject,'inlineChoice');assert choice is not None
 toggle=root.findChild(QObject,'choiceToggle');point=toggle.mapToScene(toggle.boundingRect().center())
 QTest.mouseClick(root,Qt.LeftButton,Qt.NoModifier,QPoint(int(point.x()),int(point.y())));QTest.qWait(150)
 assert choice.property('opened')
 root.grabWindow().save(str(out/(tool+'-options.png')))
 option=visual_find(root.contentItem(),'choiceOption-1');point=option.mapToScene(option.boundingRect().center())
 QTest.mouseClick(root,Qt.LeftButton,Qt.NoModifier,QPoint(int(point.x()),int(point.y())));QTest.qWait(150)
 assert choice.property('currentText')==expected and not choice.property('opened')
root.setProperty('page','control');QTest.qWait(200)
tray=visual_find(root.contentItem(),'tray-icon-test');assert tray is not None
point=tray.mapToScene(tray.boundingRect().center());point=QPoint(int(point.x()),int(point.y()))
QTest.mouseClick(root,Qt.LeftButton,Qt.NoModifier,point);QTest.qWait(50);assert root.property('trayActivations')==1
QTest.mouseClick(root,Qt.RightButton,Qt.NoModifier,point);QTest.qWait(50);assert root.property('trayQuits')==1
for detail in ['nightlight','wifi','bluetooth']:
 root.setProperty('detail','');root.setProperty('detail',detail);root.setProperty('page','detail');QTest.qWait(200);root.grabWindow().save(str(out/(detail+'.png')))
print('Rendered panel fixtures. Mouse selection and tray activate/quit tests passed with mock services.')

root.setProperty('page','control');QTest.qWait(100)
wifi=root.findChild(QObject,'control-Wi-Fi');assert wifi is not None
point=wifi.mapToScene(wifi.boundingRect().center());point=QPoint(int(point.x()),int(point.y()))
QTest.mouseClick(root,Qt.LeftButton,Qt.NoModifier,point);QTest.qWait(50);assert root.property('wifiToggles')==1
QTest.mouseClick(root,Qt.RightButton,Qt.NoModifier,point);QTest.qWait(50);assert root.property('wifiToggles')==1
print('Wi-Fi left click toggles once; right click does not toggle.')

print("Preview output:",out)
