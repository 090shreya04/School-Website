
import re
import sys

def check_file_braces(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find ALL scriptlets (not expressions)
    matches = re.finditer(r'<%([\s\S]*?)%>', content)
    
    total_open = 0
    total_close = 0
    
    for match in matches:
        scriptlet = match.group(1)
        if scriptlet.startswith('=') or scriptlet.startswith('@') or scriptlet.startswith('--'):
            continue
            
        # Simple cleanup
        code = re.sub(r'//.*', '', scriptlet)
        code = re.sub(r'/\*[\s\S]*?\*/', '', code)
        code = re.sub(r'"(?:\\.|[^"\\])*"', '""', code)
        code = re.sub(r"'(?:\\.|[^'\\])*'", "''", code)
        
        open_c = code.count('{')
        close_c = code.count('}')
        
        diff = open_c - close_c
        total_open += open_c
        total_close += close_c
        
        if diff != 0:
            line_n = content.count('\n', 0, match.start()) + 1
            print(f"Line {line_n}: open={open_c}, close={close_c}, diff={diff}")
        
    print(f"Total Open: {total_open}")
    print(f"Total Close: {total_close}")
    print(f"Difference: {total_open - total_close}")

if __name__ == "__main__":
    check_file_braces(sys.argv[1])
