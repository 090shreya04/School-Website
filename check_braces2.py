"""
Track Java control-flow brace balance across ALL scriptlets in a JSP file.
This correctly handles braces inside string literals and comments.
"""

file_path = r"C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp"

with open(file_path, encoding="utf-8") as f:
    content = f.read()

# We'll track all scriptlet content with line numbers
# and parse braces carefully (skipping inside strings and single-line comments)

def extract_scriptlets(content):
    """Extract all <% ... %> scriptlet content (not <%@, <%=, or <%--) with line numbers."""
    scriptlets = []
    i = 0
    while i < len(content):
        if content[i:i+4] == '<%--':
            end = content.find('--%>', i+4)
            if end == -1: break
            i = end + 4
        elif content[i:i+3] in ('<%=', '<%@'):
            end = content.find('%>', i+3)
            if end == -1: break
            i = end + 2
        elif content[i:i+2] == '<%':
            end = content.find('%>', i+2)
            if end == -1: break
            line_no = content[:i].count('\n') + 1
            scriptlets.append((line_no, content[i+2:end]))
            i = end + 2
        else:
            i += 1
    return scriptlets

def count_braces_java(java_code, start_line):
    """
    Count braces in Java code, skipping string literals and // comments.
    Returns list of (offset, type, running_balance, line_in_code)
    """
    events = []
    balance = 0
    i = 0
    lines_so_far = 0
    while i < len(java_code):
        c = java_code[i]
        if c == '\n':
            lines_so_far += 1
            i += 1
        elif c == '/' and i+1 < len(java_code) and java_code[i+1] == '/':
            # Single-line comment: skip to end of line
            while i < len(java_code) and java_code[i] != '\n':
                i += 1
        elif c == '/' and i+1 < len(java_code) and java_code[i+1] == '*':
            # Block comment
            end = java_code.find('*/', i+2)
            if end == -1: break
            lines_so_far += java_code[i:end+2].count('\n')
            i = end + 2
        elif c == '"':
            # String literal
            i += 1
            while i < len(java_code):
                if java_code[i] == '\\':
                    i += 2
                elif java_code[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        elif c == "'":
            # Char literal
            i += 1
            while i < len(java_code):
                if java_code[i] == '\\':
                    i += 2
                elif java_code[i] == "'":
                    i += 1
                    break
                else:
                    i += 1
        elif c == '{':
            balance += 1
            events.append((start_line + lines_so_far, '+', balance))
            i += 1
        elif c == '}':
            balance -= 1
            events.append((start_line + lines_so_far, '-', balance))
            i += 1
        else:
            i += 1
    return events, balance

scriptlets = extract_scriptlets(content)
print(f"Found {len(scriptlets)} scriptlet blocks\n")

# Track global balance across all scriptlets
global_balance = 0
all_events = []

for start_line, code in scriptlets:
    events, delta = count_braces_java(code, start_line)
    for line_no, op, bal in events:
        adjusted_bal = global_balance + bal
        all_events.append((line_no, op, adjusted_bal))
    global_balance += delta

print(f"Final global brace balance across all scriptlets: {global_balance}")

if global_balance != 0:
    print(f"\n❌ PROBLEM: {abs(global_balance)} {'unclosed {' if global_balance > 0 else 'extra }'} brace(s)!")
    print("\nLast 20 brace events to find where balance diverges:")
    for line_no, op, bal in all_events[-20:]:
        marker = " ← LAST BALANCED" if bal == 0 else ""
        marker2 = " ← STILL OPEN" if bal > 0 and op == '+' else ""
        print(f"  Line {line_no:5d} | {'OPEN ' if op=='+' else 'CLOSE'} | Balance={bal:4d}{marker}{marker2}")
    
    # Find first unmatched open
    print(f"\nSearching for the unmatched open brace(s)...")
    stack = []
    all_lines = content.splitlines()
    for start_line, code in scriptlets:
        events, _ = count_braces_java(code, start_line)
        for line_no, op, _ in events:
            if op == '+':
                stack.append(line_no)
            elif op == '-' and stack:
                stack.pop()
    
    print(f"Unmatched open brace line(s):")
    for ln in stack:
        print(f"  Line {ln}: {all_lines[ln-1].strip()[:100]}")
else:
    print("✅ Braces are perfectly balanced across all scriptlets!")
