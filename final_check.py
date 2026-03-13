
import re

content = open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8').read()

matches = re.finditer(r'<%([\s\S]*?)%>', content)

total_open = 0
total_close = 0

for match in matches:
    s = match.group(1)
    if s.startswith('=') or s.startswith('@') or s.startswith('--'):
        continue
        
    start_pos = match.start()
    line_num = content.count('\n', 0, start_pos) + 1
    
    s_clean = re.sub(r'//.*', '', s)
    s_clean = re.sub(r'/\*[\s\S]*?\*/', '', s_clean)
    s_clean = re.sub(r'"(?:\\.|[^"\\])*"', '""', s_clean)
    s_clean = re.sub(r"'(?:\\.|[^'\\])*'", "''", s_clean)
    
    o = s_clean.count('{')
    c = s_clean.count('}')
    
    if o != c:
        print(f"Line {line_num}: {{{o} }} {c} diff={o-c}")
    
    total_open += o
    total_close += c

print(f"Total Open: {total_open}")
print(f"Total Close: {total_close}")
print(f"Diff: {total_open - total_close}")
