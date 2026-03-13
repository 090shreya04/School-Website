
import sys

def find_at_around(filename, line_num):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    start = max(0, line_num - 50)
    end = min(len(lines), line_num + 50)
    
    for i in range(start, end):
        if "@" in lines[i]:
            print(f"Line {i+1}: {lines[i].strip()}")

if __name__ == "__main__":
    find_at_around(r"c:\Users\1469s\OneDrive\Desktop\project1\src\main\webapp\WEB-INF\views\adashboard.jsp", 1999)
