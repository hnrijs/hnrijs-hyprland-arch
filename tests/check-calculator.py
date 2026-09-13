"""Requires qalc; uses cached exchange rates and never downloads rates."""
import importlib.util,re
from pathlib import Path
p=Path(__file__).resolve().parents[1]/'config/scripts/calculator.py'
s=importlib.util.spec_from_file_location('calculator',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
cases={'15% of 240':36,'10 psi to bar':0.6894757293,'1 in to cm':2.54,'10 m/s to km/h':36,'2 kW * 3 h to kWh':6,'-5 + 2':-3,'1 nm to mm':0.000001,'20 degC to degF':68,'(20) degC to K':293.15,'1 byte to bit':8,'100+15%':115}
for expression,expected in cases.items():
 text=m.calculate(expression)['text'].replace('−','-')
 number=float(re.search(r'-?\d+(?:\.\d+)?(?:E[+-]?\d+)?',text)[0])
 assert abs(number-expected)<max(1e-8,abs(expected)*1e-8),(expression,text)
print(f'PASS: {len(cases)} actual Qalculate expressions including percent, temperature and pressure')
