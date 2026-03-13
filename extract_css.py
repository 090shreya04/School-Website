
import re
with open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8') as f:
    content = f.read()
m = re.search(r'<style>([\s\S]*?)</style>', content)
css = m.group(1).strip()
with open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\css\adashboard.css', 'w', encoding='utf-8') as f:
    f.write(css)
print('Done. CSS length:', len(css))
