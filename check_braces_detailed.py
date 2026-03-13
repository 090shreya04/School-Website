
import re
import sys

def check_jsp_braces_detailed(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    matches = list(re.finditer(r'<%(@|!|=|--)?([\s\S]*?)%>', content))
    
    total_open = 0
    for match in matches:
        prefix = match.group(1)
        scriptlet = match.group(2)
        start_pos = match.start()
        line_num = content.count('\n', 0, start_pos) + 1
        
        if line_num < 1900 or line_num > 2100:
            # We still need to track the total_open, but don't print
            pass
        else:
            print(f"--- Scriptlet at line {line_num} ---")
            print(f"Prefix: {prefix}")
            
        if prefix in ('=', '@', '--'): 
            continue
            
        clean_code = re.sub(r'//.*', '', scriptlet)
        clean_code = re.sub(r'/\*[\s\S]*?\*/', '', clean_code)
        clean_code = re.sub(r'"(?:\\.|[^"\\])*"', '""', clean_code)
        clean_code = re.sub(r"'(?:\\.|[^'\\])*'", "''", clean_code)
        
        open_count = clean_code.count('{')
        close_count = clean_code.count('}' )
        
        diff = open_count - close_count
        total_open += diff
        
        if 1900 <= line_num <= 2100:
            print(f"Open: {open_count}, Close: {close_count}, Diff: {diff}, Running: {total_open}")
            print(f"Code: {scriptlet.strip()[:200]}...")

    print(f"Final unbalanced count: {total_open}")

if __name__ == "__main__":
    check_jsp_braces_detailed(sys.argv[1])
