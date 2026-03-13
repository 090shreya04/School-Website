
import re

with open(r'c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', 'r', encoding='utf-8') as f:
    lines = f.readlines()

content = "".join(lines)
matches = re.finditer(r'<%([\s\S]*?)%>', content)

cumulative_balance = 0
for match in matches:
    s = match.group(1).strip()
    if s.startswith('@') or s.startswith('='):
        continue
    
    start_line = content[:match.start()].count('\n') + 1
    
    # We need to ignore braces inside strings and comments
    # Simple state machine or regex to strip strings/comments
    stripped = re.sub(r'".*?"', '', s)
    stripped = re.sub(r"'.*?'", '', stripped)
    stripped = re.sub(r'//.*?\n', '\n', stripped)
    stripped = re.sub(r'/\*.*?\*/', '', stripped, flags=re.DOTALL)
    
    open_count = stripped.count('{')
    close_count = stripped.count('}')
    cumulative_balance += (open_count - close_count)
    
    if cumulative_balance < 0:
         print(f"ERROR: Negative balance at line {start_line}: {cumulative_balance}")
    
    # print(f"Line {start_line}: balance change {open_count - close_count}, total {cumulative_balance}")

print(f"Final cumulative balance: {cumulative_balance}")
