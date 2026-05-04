<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect("/signin");
        return;
    }
    
    String cls = request.getParameter("class");
    String sec = request.getParameter("section");
    String tid = request.getParameter("teacher_id");
    
    if(cls == null || sec == null || tid == null) {
        response.sendRedirect("/adashboard?page=attendance&error=missing_params");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance - <%= cls %>-<%= sec %></title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary: #0c1a2e;
            --accent: #f97316;
            --bg: #f8fafc;
            --card: #ffffff;
            --border: #e2e8f0;
            --text: #0c1a2e;
            --muted: #64748b;
        }
        body {
            font-family: 'Sora', sans-serif;
            background: var(--bg);
            color: var(--text);
            padding: 40px 20px;
        }
        .container-custom {
            max-width: 900px;
            margin: 0 auto;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .attendance-card {
            background: var(--card);
            border: 1.5px solid var(--border);
            border-radius: 20px;
            padding: 0;
            overflow: hidden;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .table thead {
            background: #f1f5f9;
        }
        .table th {
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 15px 20px;
            border: none;
        }
        .table td {
            padding: 15px 20px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }
        .radio-group {
            display: flex;
            gap: 10px;
        }
        .radio-item input {
            display: none;
        }
        .radio-item label {
            cursor: pointer;
            padding: 8px 16px;
            border-radius: 10px;
            border: 1.5px solid var(--border);
            font-size: 12px;
            font-weight: 700;
            transition: all 0.2s;
        }
        .radio-item input[value="present"]:checked + label {
            background: #d1fae5;
            border-color: #10b981;
            color: #059669;
        }
        .radio-item input[value="absent"]:checked + label {
            background: #fee2e2;
            border-color: #ef4444;
            color: #dc2626;
        }
        .save-bar {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--primary);
            color: #fff;
            padding: 15px 40px;
            border-radius: 50px;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
            z-index: 1000;
        }
        .save-btn {
            background: var(--accent);
            border: none;
            color: #fff;
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .save-btn:hover {
            transform: scale(1.05);
        }
    </style>
</head>
<body>
    <div class="container-custom">
        <div class="header">
            <div>
                <h2 style="font-weight: 800; margin: 0;">Mark Attendance</h2>
                <p style="color: var(--muted); margin: 5px 0 0 0;">
                    Class: <strong><%= cls %></strong> | Section: <strong><%= sec %></strong> | Date: <strong><%= new java.util.Date() %></strong>
                </p>
            </div>
            <% 
                String role_val = (String) session.getAttribute("role");
                String dashboardLink = "admin".equalsIgnoreCase(role_val) ? "/adashboard?page=attendance" : "/tdashboard?page=attendance";
            %>
            <a href="<%= dashboardLink %>" class="btn btn-light" style="border-radius: 12px; font-weight: 600; padding: 10px 20px;">
                <i class="bi bi-arrow-left me-2"></i>Back to Dashboard
            </a>
        </div>

        <form action="/saveAttendance" method="post" id="attForm">
            <input type="hidden" name="class" value="<%= cls %>">
            <input type="hidden" name="section" value="<%= sec %>">
            <input type="hidden" name="teacher_id" value="<%= tid %>">
            
            <div class="attendance-card">
                <table class="table mb-0">
                    <thead>
                        <tr>
                            <th style="width: 100px;">Roll No</th>
                            <th>Student Name</th>
                            <th style="text-align: right;">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection conn = null;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3308/project1", "root", "");
                                String sql = "SELECT student_id, name, roll_no FROM students WHERE class=? AND section=? ORDER BY CAST(roll_no AS UNSIGNED)";
                                PreparedStatement pstmt = conn.prepareStatement(sql);
                                pstmt.setString(1, cls);
                                pstmt.setString(2, sec);
                                ResultSet rs = pstmt.executeQuery();
                                int count = 0;
                                while(rs.next()) {
                                    count++;
                                    String sid = rs.getString("student_id");
                                    String name = rs.getString("name");
                                    String roll = rs.getString("roll_no");
                        %>
                        <tr>
                            <td style="font-weight: 700; color: var(--accent);"><%= roll %></td>
                            <td style="font-weight: 600;"><%= name %></td>
                            <td>
                                <div class="radio-group justify-content-end">
                                    <div class="radio-item">
                                        <input type="radio" name="status_<%= sid %>" value="present" id="p_<%= sid %>" checked>
                                        <label for="p_<%= sid %>"><i class="bi bi-check-circle-fill me-1"></i>Present</label>
                                    </div>
                                    <div class="radio-item">
                                        <input type="radio" name="status_<%= sid %>" value="absent" id="a_<%= sid %>">
                                        <label for="a_<%= sid %>"><i class="bi bi-x-circle-fill me-1"></i>Absent</label>
                                    </div>
                                </div>
                                <input type="hidden" name="student_ids" value="<%= sid %>">
                            </td>
                        </tr>
                        <%
                                }
                                if(count == 0) {
                        %>
                        <tr>
                            <td colspan="3" style="text-align: center; padding: 50px; color: var(--muted);">
                                No students found for this class and section.
                            </td>
                        </tr>
                        <%
                                }
                            } catch(Exception e) {
                                out.println("Error: " + e.getMessage());
                            } finally {
                                if(conn != null) conn.close();
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="save-bar">
                <span style="font-size: 14px; opacity: 0.8;">Marking for today</span>
                <button type="button" class="save-btn" onclick="document.getElementById('attForm').submit()">
                    <i class="bi bi-cloud-upload-fill me-2"></i>Submit Attendance
                </button>
            </div>
        </form>
    </div>
</body>
</html>
