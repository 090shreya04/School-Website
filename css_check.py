
import re

with open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8') as f:
    content = f.read()

# Extract CSS block
m = re.search(r'<style>([\s\S]*?)</style>', content)
if not m:
    print("No style block found")
    exit()

css = m.group(1)
start_line = content[:m.start(1)].count('\n') + 1

opens = 0
for i, ch in enumerate(css):
    if ch == '{':
        opens += 1
    elif ch == '}':
        opens -= 1

print(f"CSS block starts at line {start_line}")
print(f"Open braces: {css.count('{')}")
print(f"Close braces: {css.count('}')}")
print(f"Balance: {opens}")
