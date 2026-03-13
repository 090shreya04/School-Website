"""
Counts braces inside JSP scriptlets (<% ... %>) to find unclosed { } pairs.
Reports the running brace balance and flags where it goes negative or ends non-zero.
"""

import re
import sys

file_path = r"C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp"

with open(file_path, encoding="utf-8") as f:
    content = f.read()

# Extract all scriptlet content with their line positions
# We need to track line numbers, so let's work line by line

lines = content.splitlines()

in_scriptlet = False
brace_count = 0
scriptlet_content = []

print("Tracking brace balance inside JSP scriptlets...")
print("="*60)

for line_no, line in enumerate(lines, 1):
    i = 0
    while i < len(line):
        if not in_scriptlet:
            # Look for <%  (but not <%@ or <%= or <%-- )
            if line[i:i+2] == '<%' and (i+2 >= len(line) or line[i+2] not in ('@', '=', '-')):
                in_scriptlet = True
                i += 2
                continue
            else:
                i += 1
        else:
            if line[i:i+2] == '%>':
                in_scriptlet = False
                i += 2
                continue
            elif line[i] == '{':
                brace_count += 1
                if brace_count > 0:
                    pass  # normal
                scriptlet_content.append((line_no, '+', brace_count, line.strip()))
                i += 1
            elif line[i] == '}':
                brace_count -= 1
                scriptlet_content.append((line_no, '-', brace_count, line.strip()))
                if brace_count < 0:
                    print(f"  ⚠️  Line {line_no}: Balance went NEGATIVE ({brace_count}): {line.strip()[:80]}")
                i += 1
            else:
                i += 1

print(f"\nFinal brace balance: {brace_count}")
if brace_count > 0:
    print(f"❌ There are {brace_count} UNCLOSED '{{' braces in scriptlets!")
    print("\nLast 30 brace events:")
    for item in scriptlet_content[-30:]:
        ln, op, bal, txt = item
        marker = "  ← LIKELY ISSUE" if bal == brace_count else ""
        print(f"  Line {ln:5d} | {'OPEN ' if op=='+' else 'CLOSE'} | Balance={bal:3d} | {txt[:60]}{marker}")
elif brace_count == 0:
    print("✅ Braces are balanced inside scriptlets.")
else:
    print(f"❌ There are {abs(brace_count)} EXTRA '}}' braces (more closes than opens)!")

print("\nAll '{{' openings that never got closed (balance > 0 at end):")
# Find the unmatched opens
running = 0
unmatched = []
for item in scriptlet_content:
    ln, op, bal, txt = item
    if op == '+':
        running += 1
        unmatched.append((ln, txt))
    else:
        running -= 1
        if unmatched:
            unmatched.pop()

print(f"  {len(unmatched)} unmatched open brace(s):")
for ln, txt in unmatched:
    print(f"    Line {ln}: {txt[:80]}")
