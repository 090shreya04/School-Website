
import re

def find_malformed_style(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Simple check for style=" ... without a closing quote
    # This is hard because of JSP tags
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'style="' in line:
            # check if closed
            # counting quotes is tricky because of \" inside strings
            pass
        
        # Check for unclosed <style> or <script>
        # (Though they seem to be closed)
    
    # Check for @ rules missing {
    at_rules = re.finditer(r'@[\w-]+\s*[^;{]*', content)
    for match in at_rules:
        start = match.start()
        end = match.end()
        # check if { or ; follows
        following = content[end:end+20].strip()
        if not following.startswith('{') and not following.startswith(';'):
            # It might be an email address, skip if it has characters before @
            if start > 0 and content[start-1].isalnum():
                continue
            line_num = content.count('\n', 0, start) + 1
            print(f"Potential malformed @ rule at {match.group()} near line {line_num}")

if __name__ == "__main__":
    find_malformed_style(r"c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp")
