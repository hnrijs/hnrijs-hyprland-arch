"""Run the actual notification timer and QML method compilation in Qt; no desktop services."""
from pathlib import Path
import os,re,tempfile
os.environ['QT_QPA_PLATFORM']='offscreen'
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine,QQmlComponent
from PySide6.QtCore import QUrl,QMetaObject
from PySide6.QtTest import QTest
app=QGuiApplication([]);engine=QQmlEngine()
source=Path(__file__).resolve().parents[1]/'config/quickshell/hshell'
names=set()
for p in source.rglob('*.qml'):
 for name in re.findall(r'function\s+(\w+)\s*\(',p.read_text()):
  c=QQmlComponent(engine);c.setData(f'import QtQml\nQtObject {{ function {name}() {{}} }}'.encode(),QUrl())
  assert not c.errors(),(p,name,[e.toString() for e in c.errors()]);names.add(name)
with tempfile.TemporaryDirectory() as work:
 root=Path(work);qs=root/'qs';qs.mkdir()
 text=(source/'NotificationCenter.qml').read_text().replace('import Quickshell','').replace('Singleton {','Item {')
 (qs/'NotificationCenter.qml').write_text(text)
 (qs/'Preferences.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property bool notifications:true; property real notificationSeconds:0.1}')
 (qs/'ShellState.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property bool dnd:false; function currentScreen(){return "DP-1"}}')
 (qs/'qmldir').write_text('module qs\nsingleton NotificationCenter 1.0 NotificationCenter.qml\nsingleton Preferences 1.0 Preferences.qml\nsingleton ShellState 1.0 ShellState.qml\n')
 engine.addImportPath(work)
 code='''import QtQuick
import qs
Item {
 property int expiredA:0
 property int expiredB:0
 property string currentName:NotificationCenter.current ? NotificationCenter.current.name : ""
 QtObject {id:a;property string name:"A";signal closed(int reason);function expire(){expiredA++;closed(0)}}
 QtObject {id:b;property string name:"B";signal closed(int reason);function expire(){expiredB++;closed(0)}}
 function first(){NotificationCenter.present(a)}
 function second(){NotificationCenter.present(b)}
 function peace(){ShellState.dnd=true}
}'''
 c=QQmlComponent(engine);c.setData(code.encode(),QUrl.fromLocalFile(str(root/'test.qml')))
 assert not c.errors(),[e.toString() for e in c.errors()]
 obj=c.create();assert obj is not None
 QMetaObject.invokeMethod(obj,'first');assert obj.property('currentName')=='A'
 QTest.qWait(30)
 QMetaObject.invokeMethod(obj,'second');assert obj.property('currentName')=='B';assert obj.property('expiredA')==1
 QTest.qWait(150);assert obj.property('currentName')=='';assert obj.property('expiredB')==1
 QTest.qWait(150);assert obj.property('expiredB')==1
 QMetaObject.invokeMethod(obj,'peace');QMetaObject.invokeMethod(obj,'first');assert obj.property('currentName')=='';assert obj.property('expiredA')==2
 obj.deleteLater();QTest.qWait(10)
print(f'PASS: {len(names)} QML method names compile; one current notification; replacement, timed expiry, no repeat expiry and Peace suppression')
