import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

# Configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "project1",
    "port": 3308
}

OUTPUT_DIR = "src/main/webapp/images/reports"

def ensure_dir(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

def generate_enrollment_report(conn):
    query = "SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count FROM user WHERE role='student' GROUP BY month ORDER BY month"
    df = pd.read_sql(query, conn)
    
    plt.figure(figsize=(10, 6))
    plt.plot(df['month'], df['count'], marker='o', color='#ea580c', linewidth=2)
    plt.fill_between(df['month'], df['count'], color='#ffedd5', alpha=0.3)
    plt.title('Student Enrollment Trends', fontsize=14, fontweight='bold', pad=20)
    plt.xlabel('Month', fontsize=12)
    plt.ylabel('New Admissions', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'enrollment_trend.png'), dpi=150)
    plt.close()

def generate_attendance_report(conn):
    query = """
        SELECT class, 
               (SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as percentage 
        FROM attendance 
        GROUP BY class
    """
    df = pd.read_sql(query, conn)
    
    plt.figure(figsize=(10, 6))
    colors = ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#ef4444']
    plt.bar(df['class'], df['percentage'], color=colors[:len(df)])
    plt.title('Average Attendance by Class', fontsize=14, fontweight='bold', pad=20)
    plt.xlabel('Class', fontsize=12)
    plt.ylabel('Attendance Percentage (%)', fontsize=12)
    plt.ylim(0, 105)
    plt.axhline(y=75, color='red', linestyle='--', label='Required (75%)')
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'attendance_by_class.png'), dpi=150)
    plt.close()

def generate_fee_report(conn):
    # Better logic: Calculate pending per student to avoid advance payments masking others
    query = """
        SELECT s.student_id, fs.monthly_fee, 
               (SELECT SUM(amount) FROM fees f WHERE f.student_id = s.student_id 
                AND MONTH(f.payment_date) = MONTH(CURRENT_DATE()) 
                AND YEAR(f.payment_date) = YEAR(CURRENT_DATE())) as paid_this_month 
        FROM students s 
        JOIN fee_structure fs ON s.class = fs.class_name
    """
    df = pd.read_sql(query, conn)
    df['paid_this_month'] = df['paid_this_month'].fillna(0)
    
    # Calculate total paid this month (strictly for this month's status)
    total_paid = df['paid_this_month'].sum()
    
    # Calculate total pending (only positive differences)
    df['pending'] = (df['monthly_fee'] - df['paid_this_month']).clip(lower=0)
    total_pending = df['pending'].sum()
    
    plt.figure(figsize=(8, 8))
    labels = ['Paid (This Month)', 'Pending']
    sizes = [total_paid, total_pending]
    colors = ['#10b981', '#ef4444']
    
    if total_paid + total_pending > 0:
        plt.pie(sizes, labels=labels, autopct='%1.1f%%', startangle=140, colors=colors, explode=(0.1, 0))
    else:
        plt.text(0.5, 0.5, 'No fee data available', ha='center', va='center')
        
    plt.title('Fee Collection Status', fontsize=14, fontweight='bold', pad=20)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fee_distribution.png'), dpi=150)
    plt.close()

def generate_performance_report(conn):
    query = "SELECT class, AVG(marks_obtained * 100.0 / total_marks) as avg_score FROM results GROUP BY class"
    df = pd.read_sql(query, conn)
    
    plt.figure(figsize=(10, 6))
    plt.barh(df['class'], df['avg_score'], color='#8b5cf6')
    plt.title('Academic Performance by Class', fontsize=14, fontweight='bold', pad=20)
    plt.xlabel('Average Score (%)', fontsize=12)
    plt.ylabel('Class', fontsize=12)
    plt.xlim(0, 100)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'academic_performance.png'), dpi=150)
    plt.close()

def main():
    print("Starting Report Generation...")
    ensure_dir(OUTPUT_DIR)
    
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        
        generate_enrollment_report(conn)
        print("Generated Enrollment Report.")
        
        generate_attendance_report(conn)
        print("Generated Attendance Report.")
        
        generate_fee_report(conn)
        print("Generated Fee Report.")
        
        generate_performance_report(conn)
        print("Generated Performance Report.")
        
        conn.close()
        print("All reports generated successfully!")
        
    except Exception as e:
        print(f"Error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
