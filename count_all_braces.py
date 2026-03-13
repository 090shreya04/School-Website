
with open(r'c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', 'r', encoding='utf-8') as f:
    content = f.read()

print("{ count:", content.count('{'))
print("} count:", content.count('}'))
