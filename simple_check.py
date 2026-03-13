
import re

content = open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8').read()
matches = re.findall(r'<%([\s\S]*?)%>', content)

total_o = 0
total_c = 0
for m in matches:
    if m.startswith('=') or m.startswith('@') or m.startswith('--'):
        continue
    total_o += m.count('{')
    total_c += m.count('}')

print(f"O: {total_o}, C: {total_c}, D: {total_o - total_c}")
