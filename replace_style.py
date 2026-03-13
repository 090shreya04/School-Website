
import re

with open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', encoding='utf-8') as f:
    content = f.read()

# Replace the entire <style>...</style> block with a link tag
new_content = re.sub(
    r'\s*<style>[\s\S]*?</style>',
    '\n            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/adashboard.css" />',
    content,
    count=1
)

with open(r'C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Done!")
