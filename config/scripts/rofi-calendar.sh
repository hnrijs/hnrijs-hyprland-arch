#!/bin/bash

sleep 0.1

CAL_TEXT=$(python3 -c "
import calendar
import datetime
import re

now = datetime.datetime.now()
year = now.year
cur_month = now.month
cur_day = now.day

cal = calendar.TextCalendar(calendar.SUNDAY)
grid = []

for row in range(3):
    m_lines_all = []
    for col in range(4):
        m = row * 4 + col + 1
        lines = cal.formatmonth(year, m).split('\n')
        
        padded_lines = []
        for l in lines:
            if not l: continue
            padded_lines.append(l.ljust(20))
            
        while len(padded_lines) < 8:
            padded_lines.append(' ' * 20)
            
        if m == cur_month:
            for i in range(2, 8):
                pattern = r'(?<!\d)' + str(cur_day) + r'(?!\d)'
                padded_lines[i] = re.sub(pattern, f'<span foreground=\"#F38BA8\"><b>{cur_day}</b></span>', padded_lines[i])
                
        m_lines_all.append(padded_lines)
        
    for line_idx in range(8):
        row_str = '    '.join(m_lines[line_idx] for m_lines in m_lines_all)
        grid.append(row_str)
    grid.append('')

print('\n'.join(grid))
")

rofi_override="
window { 
    width: 1200px; 
}
textbox { 
    font: \"monospace 15\"; 
    padding: 30px 40px 30px 40px; 
    markup: true;
    text-color: #cdd6f4;
    background-color: transparent;
}
"
rofi -markup -normal-window -theme-str "${rofi_override}" -e "$CAL_TEXT"
