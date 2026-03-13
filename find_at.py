
import sys

def find_chars(filename, start_line, end_line):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for i in range(start_line - 1, min(end_line, len(lines))):
        line = lines[i]
        print(f"{i+1}: {line.strip()}")
        for j, char in enumerate(line):
            if char in "{@}":
                print(f"  Found '{char}' at col {j+1}")

if __name__ == "__main__":
    find_chars(r"c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp", 1990, 2010)
