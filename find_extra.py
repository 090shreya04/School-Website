
import re
import sys

def find_extra_closes(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = re.finditer(r'<%([\s\S]*?)%>', content)
    
    for match in matches:
        scriptlet = match.group(1)
        if scriptlet.startswith('=') or scriptlet.startswith('@') or scriptlet.startswith('--'):
            continue
            
        clean_code = re.sub(r'//.*', '', scriptlet)
        clean_code = re.sub(r'/\*[\s\S]*?\*/', '', clean_code)
        clean_code = re.sub(r'"(?:\\.|[^"\\])*"', '""', clean_code)
        clean_code = re.sub(r"'(?:\\.|[^'\\])*'", "''", clean_code)
        
        open_count = clean_code.count('{')
        close_count = clean_code.count('}')
        
        if close_count > open_count:
            line_num = content.count('\n', 0, match.start()) + 1
            print(f"Potential extra closes at line {line_num}: open={open_count}, close={close_count}")
            print(f"Code: {scriptlet.strip()!r}")

if __name__ == "__main__":
    find_extra_closes(sys.argv[1])
