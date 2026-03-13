
import re

def find_malformed_attributes(filename):
    # Regex to find HTML attributes that use double quotes and contain JSP expressions with double quotes
    # Example: data-class="<%= stRs.getString("class") %>"
    # We look for something like name="<%= ... " ... %>"
    pattern = re.compile(r'(\w+)\s*=\s*"[^"]*<%=.*?["\'].*?%>[^"]*"')
    # Actually, a simpler way to detect this is to look for "=" followed by "<%=" and then another " before the closing "%>"
    # but that's tricky with regex.
    
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.splitlines()
        for i, line in enumerate(lines):
            # Find attributes like attr="<%= ... " ... %>"
            # This regex matches attr=" followed by anything, then <%=, then anything including a quote, then %>, then anything then "
            # Wait, the simple logic is: if a line has =" and then <%= and then " before %>
            if re.search(r'="[^"]*<%=[^%]*"[^%]*%>', line):
                print(f"Potential malformed attribute at line {i+1}: {line.strip()}")

find_malformed_attributes(r'c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp')
