"""
Check for mismatched <% and %> tags in a JSP file.
Also look for <%-- comments and <%= expressions to be comprehensive.
"""

file_path = r"C:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp"

with open(file_path, encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# Count all JSP tag openings vs closings
opens = []   # (line_no, type, context)
events = []

i = 0
while i < len(content):
    # Track current line number
    line_no = content[:i].count('\n') + 1

    if content[i:i+4] == '<%--':
        # JSP comment
        end = content.find('--%>', i+4)
        if end == -1:
            print(f"⚠️  Unclosed JSP comment <%-- at line {line_no}")
            break
        i = end + 4
    elif content[i:i+3] == '<%=':
        # Expression tag
        end = content.find('%>', i+3)
        if end == -1:
            print(f"❌  UNCLOSED <%= expression at line {line_no}!")
            context_end = min(i+80, len(content))
            print(f"    Context: {content[i:context_end]!r}")
            break
        i = end + 2
    elif content[i:i+3] == '<%@':
        # Directive  
        end = content.find('%>', i+3)
        if end == -1:
            print(f"❌  UNCLOSED <%@ directive at line {line_no}!")
            break
        i = end + 2
    elif content[i:i+2] == '<%':
        # Scriptlet
        end = content.find('%>', i+2)
        if end == -1:
            print(f"❌  UNCLOSED <% scriptlet at line {line_no}!")
            context_end = min(i+200, len(content))
            print(f"    Context: {content[i:context_end]!r}")
            break
        events.append(('scriptlet', line_no, content[i:min(i+60, end+2)]))
        i = end + 2
    else:
        i += 1

print("\nAll scriptlet blocks found (first 5 and last 5):")
for evt in events[:5]:
    print(f"  Line {evt[1]:4d}: {evt[2]!r}")
print("  ...")
for evt in events[-5:]:
    print(f"  Line {evt[1]:4d}: {evt[2]!r}")

print(f"\nTotal scriptlet blocks: {len(events)}")
print("✅ All JSP tags appear properly closed" if events else "")

# Now also count the raw <% and %> counts
raw_opens = content.count('<%')
raw_closes = content.count('%>')
print(f"\nRaw counts: <% appears {raw_opens} times, %> appears {raw_closes} times")
if raw_opens != raw_closes:
    print(f"❌ Mismatch! Difference = {raw_opens - raw_closes}")
else:
    print("✅ Equal counts of <% and %>")
