
import re

content = open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8').read()
matches = re.finditer(r'<%([\s\S]*?)%>', content)

total_open = 0
total_close = 0
running_total = 0

for match in matches:
    s = match.group(1)
    s_strip = s.lstrip()
    if s_strip.startswith('=') or s_strip.startswith('@') or s_strip.startswith('--'):
        continue
        
    s_clean = re.sub(r'//.*', '', s)
    s_clean = re.sub(r'/\*[\s\S]*?\*/', '', s_clean)
    s_clean = re.sub(r'"(?:\\.|[^"\\])*"', '""', s_clean)
    s_clean = re.sub(r"'(?:\\.|[^'\\])*'", "''", s_clean)
    
    o = s_clean.count('{')
    c = s_clean.count('}')
    running_total += (o - c)
    
    line_num = content.count('\n', 0, match.start()) + 1
    print(f"Line {line_num}: o={o}, c={c}, running={running_total}")
    if running_total < 0:
        print(f"NEGATIVE at {line_num}")
        # Reset to 0 to find the next error
        # Actually, don't reset, just keep going
